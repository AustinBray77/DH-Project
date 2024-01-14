import redis
import redis.typing
import math

redis_connection = redis.Redis(
    host="redis-13421.c322.us-east-1-2.ec2.cloud.redislabs.com", port=13421,
    username="default", # use your Redis user. More info https://redis.io/docs/management/security/acl/
    password="KTUdStQTYcAGTS4zj1HjTyCMAOBbzypE", # use your Redis password
    ssl=False,
    #ssl_certfile="./redis_user.crt"
    #ssl_keyfile="./redis_user_private.key",
    #ssl_ca_certs="./redis_ca.pem",
  ) 

# People are stored by their email
# Person
# Email : String
# Name : String
# Password : String
# Role : Int (0: Reporter, 1: Volunteer 2: Finder)

#Cat (
#ID: string
#Description: string
#Colour: string
#locationX: float
#locationY: float, 
#Date Found: int, 
#Photo: image (ignore for now)

catPrefix = "cat:"
personPrefix = "person:"

catSet = "cats"
peopleSet = "people"

def buildPersonHash (name : str, password : str, role : int):
  return {
    "name" : name, 
    "password" : password, 
    "role" : role
    }

def addPerson (email, name, password, role) -> bool:
  if redis_connection.sismember(peopleSet, email):
    return False
  else:
    redis_connection.sadd(peopleSet, email)
    redis_connection.hset(personPrefix + email, mapping = buildPersonHash(name, password, role))
    return True

def buildCatHash (description, colour, locationX, locationY, dateFound):
  return {
    "description" : description,
    "colour" : colour,
    "locationX" : locationX,
    "locationY" : locationY,
    "date found" : dateFound
  }

def addCat(id, description, colour, locationX, locationY, dateFound):
  if redis_connection.sismember(catSet, str(id)):
    return False
  else:
    redis_connection.sadd(catSet, id)
    redis_connection.hset(catPrefix + str(id), mapping = buildCatHash(description, colour, locationX, locationY, dateFound))
    return True

#Check Valid Login
#Input (email: string, password: string)
#Output (result: boolean, name, role: int)
#Checks if a users information is valid to login
def checkValidLogin (email, password):
  if redis_connection.hget(personPrefix + email, "password") == password:
    return {
      "successful" : True, 
      "name" : redis_connection.hget(personPrefix + email, "name"),
      "role" : redis_connection.hget(personPrefix + email, "role")
    }
  else:
    return {"successful": False}

#gets the distance between two points in latitude and longitude (in meters)
def distanceBetweenPoints(lat1, long1, lat2, long2):
#ACOS((SIN(RADIANS(Lat1)) * SIN(RADIANS(Lat2))) + (COS(RADIANS(Lat1)) * COS(RADIANS(Lat2))) * (COS(RADIANS(Lon2) - RADIANS(Lon1)))) * 6371
  radius = 6371000
  lat1Rad, lat2Rad = math.radians(lat1), math.radians(lat2)
  deltaLatRad = math.radians(lat2 - lat1)
  deltaLongRad = math.radians(long2 - long1)

  a = (math.sin(deltaLatRad / 2) ** 2) + (math.cos(lat1Rad) * math.cos(lat2Rad) * (math.sin(deltaLongRad / 2) ** 2))
  c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
  return radius * c

#Get Cats Radius and Time
#Input (locationX: float, locationY: float, radius: float, date: int, dateDiff: int)
#Output (List of dictionaries containing all of the info about the cats)
#Gets cats in a given radius and timeframe
def getCatsWithinLocationAndTime(centerLat, centerLong, date, radius = -1, dateDiff = -1, colour = ""):
  allCats = redis_connection.smembers(catSet)
  validCats = []
  for cat in allCats:
    catDict = redis_connection.hgetall(catPrefix + str(cat))
    
    #check if cat wasn't found recently enough
    if dateDiff > 0 and date - catDict["dateFound"] > dateDiff:
      continue

    #check if colour doesn't matches
    if colour != "" and colour != catDict["colour"]:
      continue

    #check if cat is too far away
    if distanceBetweenPoints(centerLat, centerLong, catDict["locationX"], catDict["locationY"]) > radius:
      continue

    #only valid cats will reach this point
    catDict["id"] = int(cat)
    validCats.append(catDict)
  
  return validCats



  








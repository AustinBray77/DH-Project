from django.shortcuts import render
from django.http import HttpResponse as Http
import DataQueries
import json
# Create your views here.
def index(request):
    return Http.HttpResponse("hello")


#Login (post url: “/login”)
#Used by all users
#Input JSON: { email: string, password: string }
#Output JSON: { role: int } + Status Code

def login(request):
    info = json.loads(request)
    loginData = DataQueries.checkValidLogin(info.email, info.password)

    if (loginData.successful):
        roleDict = {"role" : loginData.role} 
        return Http.response(json.dumps(roleDict), status = Http.status.HTTP_200_OK)
    else:
        return Http.response(json.dumps({}), status = Http.status.HTTP_400_BAD_REQUEST)

# SignUp (post url: “/sign-up”)
# Used by all users
# Input JSON: { name: string, email: string, password: string, role: int }
# Output JSON: { role: int } + Status Code
        # json.loads()

def signup(request):
    info = json.loads(request)
    signupData = DataQueries.addPerson(info.email, info.name, info.password, info.role)

    if (signupData):
        roleDict = {"role" : signupData.role}
        return Http.response(json.dumps(roleDict),status = Http.status.HTTP_200_OK)
    else:
        return Http.response(json.dumps({}), status = Http.status.HTTP_400_BAD_REQUEST)
    
#Update Map (post url: “/update-map”)
#Used by the volunteer
#Input JSON: { time: int, locationX: float, locationY: float }
#Output JSON: { cats: [ { description: string, color: string, locationX: float, locationY: y, date: int, photo: image } ] } 
#Returns a list of locations of current cats in a given radius and timeframe
def updateMap(request):
    info = json.loads(request)
    cats = DataQueries.getCatsWithinLocationAndTime(info.locationX, info.locationY, info.time, dateDiff = info.timeDiff, radius = info.radius)
    return Http.response(json.dumps(cats), Http.status.HTTP_200_OK)


#Report (post url: “/report”)
#Used by reporter
#Input JSON: { description: string, color: string, locationX: float, locationY: float, time: int }
#Output: Status Code
#Adds a cat to the database
def reportCat(request):
    info = json.loads(request)
    id = DataQueries.getHighestCatId() + 1
    DataQueries.addCat(id, info.description, info.colour, info.locationX, info.locationY, info.time)
    return Http.response("", Http.status.HTTP_200_OK)

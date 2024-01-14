from django.shortcuts import render
from django.http import HttpResponse
import DataQueries
import json
# Create your views here.
def index(request):
    return HttpResponse("hello")


#Login (post url: “/login”)
#Used by all users
#Input JSON: { email: string, password: string }
#Output JSON: { role: int } + Status Code

def login(request):
    info = json.loads(request)
    loginData = checkValidLogin(info.email, info.password)

    if (loginData.successful):
        roleDict = {"role" : loginData.role} 
        return response(json.dumps(roleDict), status = status.HTTP_200_OK)
    else:
        return response(json.dumps({}), status = status.HTTP_400_BAD_REQUEST)

# SignUp (post url: “/sign-up”)
# Used by all users
# Input JSON: { name: string, email: string, password: string, role: int }
# Output JSON: { role: int } + Status Code
        # json.loads()

def signup(request):
    info = json.loads(request)
    signupData = addPerson(info.email, info.name, info.password, info.role)

    if (signupData):
        roleDict = {"role" : signupData.role}
        return response(json.dumps(roleDict),status = status.HTTP_200_OK)
    else:
        return response(json.dumps({}), status = status.HTTP_400_BAD_REQUEST)
    
# Respond (post url: “/respond”)
# Used by volunteer and finder
# Input JSON: { id: string, update_state: int }
# Output: Status Code 
# Updates information about a cat, possibly removes it from the database




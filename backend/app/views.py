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
    loginData = checkValidLogin(request.email, request.password)

    if (loginData.successful):
        roleDict = {"role" : loginData.role} 
        return response(json.dumps(roleDict), status = status.HTTP_200_OK)
    else:
        return response(json.dumps({}), status = status.HTTP_400_BAD_REQUEST)


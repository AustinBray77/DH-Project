from django.shortcuts import render
from django.http import HttpResponse
import DataQueries
# Create your views here.
def index(request):
    return HttpResponse("hello")


#Login (post url: “/login”)
#Used by all users
#Input JSON: { email: string, password: string }
#Output JSON: { role: int } + Status Code

def login(request):
    #loginData
    pass
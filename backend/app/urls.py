from django.urls import path

from . import views

urlpatterns = [
    path("index/", views.index, name="index"),
    path("login/", views.login, name="login"),
    path("signup/", views.signup, name = "signup"),
    path("updateMap/", views.updateMap, name = "update Map"),
    path("report/", views.reportCat, name = "report")
]


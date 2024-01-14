from django.urls import path

from . import views

urlpatterns = [
    path("", views.index, name="index"),
    path("login/", views.login, name="login"),
    path("sign-up/", views.signup, name = "signup"),
    path("update-map/", views.updateMap, name = "update Map"),
    path("report/", views.reportCat, name = "report")
]


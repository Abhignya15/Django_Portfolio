from django.contrib import messages
from django.shortcuts import redirect, render, HttpResponse
from home.models import Contact
# render is used to render the template 
# Create your views here.
def index(request):
    # render is used to directly talk to the templates folder 
    context={
        "variable":"this is sent",
        "variable2":"This is the second one"
    }
    return render(request,'index.html',context)

def about(request):
    # http response is used to direclty print out the text 
    return HttpResponse("This is the about page")

def experience(request):
    return render(request,'experience.html')

def achievements(request):
    return render(request,'achievements.html')

def contact(request):
    if request.method == "POST":
        name = request.POST.get('name', '').strip()
        email = request.POST.get('email', '').strip()
        subject = request.POST.get('subject', '').strip()
        desc = request.POST.get('desc', '').strip()

        if not name or not email or not desc:
            messages.error(request, "Name, email, and message are required.")
            return render(request, 'contact.html', {
                'form_data': request.POST,
            })

        Contact.objects.create(name=name, email=email, subject=subject, desc=desc)
        messages.success(request, "Thanks for reaching out. I will get back to you soon.")
        return redirect('contact')
    return render(request,'contact.html')
# def contact(request):
#     return HttpResponse("This is the contact page ")
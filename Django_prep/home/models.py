from django.db import models
# make migrations : create changes and store it in a file 
# migrate : apply the pending changes created by makemigrations
# To store the contact 
class Contact(models.Model):
    name = models.CharField(max_length=122)
    email = models.CharField(max_length=122)
    subject = models.TextField()
    desc = models.TextField()
    def __str__(self):
        return self.name
import Skype4Py
import time
import os

def Commands(Message, Status):
	os.system('lua main.luac \'{"message":"' + (((Message.Body).replace('"','')).replace("'",'')).encode('ascii','ignore') + '","sender":"' + (((Message.FromDisplayName).replace('"','')).replace("'",'')).encode('ascii','ignore') + '","username":"' + Message.FromHandle + '","status":"' + Status.encode('ascii','ignore') + '"}\'')

def AcceptFriend(user):
    user._SetIsAuthorized(1)
    time.sleep(2)
    skype.SendMessage(user.Handle,"Hello! I am a robot designed to notify you when your name is mentioned. Type !help for more information!")

skype = Skype4Py.Skype()
skype.FriendlyName = "Candunc's Skypebot | Reciever"
skype.OnMessageStatus = Commands
skype.OnUserAuthorizationRequestReceived = AcceptFriend
skype.Attach()
while True:
	time.sleep(0.5)
	pass
import Skype4Py
import sys

skype = Skype4Py.Skype()
skype.FriendlyName = "Candunc's Skypebot | Sender"
skype.Attach()
skype.SendMessage(sys.argv[1],sys.argv[2])
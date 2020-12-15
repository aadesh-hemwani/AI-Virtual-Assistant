# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

from typing import Any, Text, Dict, List

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
import webbrowser
from bs4 import BeautifulSoup as soup
from urllib.request import Request, urlopen
import json
from joke.jokes import *
from random import choice
import wikipedia

class ActionSearchGoogle(Action):
    def name(self) -> Text:
        return "action_google_search"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        print(tracker.latest_message)
        for blob in tracker.latest_message['entities']:
            if blob['entity'] == 'search_entity':
                name = blob['value']
                dispatcher.utter_message(text="wait i am finding information on "+name)
                webbrowser.open('http://google.com/search?q='+name, new=2)
        print("************************************************************")
        return []
        
class ActionTime(Action):
    def name(self) -> Text:
        return "action_time"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        print(tracker.latest_message)
        for blob in tracker.latest_message['entities']:
            if blob['entity'] == 'location':
                location = blob['value']
                req = Request('http://google.com/search?q=time%20in%20'+location, headers={'User-Agent': 'Mozilla/5.0'})
                webpage = urlopen(req).read()
                page_soup = soup(webpage, "html.parser")
                time = page_soup.find_all("div", {"class": "BNeawe iBp4i AP7Wnd"})
                location_name = page_soup.findAll("span", {"class": "r0bn4c rQMQod"})
                print(location_name[1].text + " is " + time[0].text)
                dispatcher.utter_message(text=location_name[1].text + " is " + time[0].text)

        print("************************************************************")
        return []
        
class ActionJoke(Action):
    def name(self) -> Text:
        return "action_joke"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        print(tracker.latest_message)
        for blob in tracker.latest_message['entities']:
            if blob['entity'] == 'chucknorris_joke_entity':
                dispatcher.utter_message(text=chucknorris())
                return
        dispatcher.utter_message(text=(choice([geek, icanhazdad, icndb])()))
        print("************************************************************")
        return []

class ActionSearchWiki(Action):
    def name(self) -> Text:
        return "action_search_wiki"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        print(tracker.latest_message)
        for blob in tracker.latest_message['entities']:
            if blob['entity'] == 'wiki_entity':
                query = blob['value']
                response =  wikipedia.summary(query, sentences=1)
                dispatcher.utter_message(text=response)
        print("************************************************************")
        return []
        
    
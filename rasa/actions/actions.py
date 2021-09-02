# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions

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
        for blob in tracker.latest_message['entities']:
            if blob['entity'] == 'search_entity':
                name = blob['value']
                dispatcher.utter_message(text='http://google.com/search?q='+name)
        return []
        
class ActionTime(Action):
    def name(self) -> Text:
        return "action_time"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        for blob in tracker.latest_message['entities']:
            if blob['entity'] == 'location':
                location = blob['value']
                req = Request('http://google.com/search?q=time%20in%20'+location, headers={'User-Agent': 'Mozilla/5.0'})
                webpage = urlopen(req).read()
                page_soup = soup(webpage, "html.parser")
                time = page_soup.find_all("div", {"class": "BNeawe iBp4i AP7Wnd"})
                location_name = page_soup.findAll("span", {"class": "r0bn4c rQMQod"})
                dispatcher.utter_message(text=location_name[1].text + " is " + time[0].text)
        return []
        
class ActionJoke(Action):
    def name(self) -> Text:
        return "action_joke"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        for blob in tracker.latest_message['entities']:
            if blob['entity'] == 'chucknorris_joke_entity':
                dispatcher.utter_message(text=chucknorris())
                return
        dispatcher.utter_message(text=(choice([geek, icanhazdad, icndb])()))
        return []

class ActionSearchWiki(Action):
    def name(self) -> Text:
        return "action_search_wiki"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        for blob in tracker.latest_message['entities']:
            if blob['entity'] == 'wiki_entity':
                query = blob['value']
                response =  wikipedia.summary(query, sentences=2)
                dispatcher.utter_message(text=response)
        return []

class ActionCalculate(Action):
    def name(self) -> Text:
        return "action_calc"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        for blob in tracker.latest_message['entities']:
            if blob['entity'] == 'equation_entity':
                query = blob['value']
                dispatcher.utter_message(text='http://google.com/search?q='+query)
        return []

        
    
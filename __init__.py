"""
MapNavigationPlaces Mycroft Skill.
"""
import re
import sys
import json
import requests
from adapt.intent import IntentBuilder
from os.path import join, dirname
from string import Template
from mycroft.skills.core import MycroftSkill, intent_handler
from mycroft.util import read_stripped_lines
from mycroft.util.log import getLogger
from mycroft.messagebus.message import Message

__author__ = 'aix'

LOGGER = getLogger(__name__)


class MapNavigationPlacesSkill(MycroftSkill):
    """
    MapNavigationPlaces Skill Class.
    """    
    def __init__(self):
        """
        Initialization.
        """
        super(MapNavigationPlacesSkill, self).__init__(name="MapNavigationPlacesSkill")
        
    @intent_handler(IntentBuilder("LocationPlaces").require("SearchPlacesKeyword").build())
    def handle_search_location_places_intent(self, message):
        """
        Handle Search Location Keyword
        """
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('SearchPlacesKeyword'), '')
        self.gui["locationQuery"] = utterance
        self.gui.show_page("mapmain.qml")
                
    def stop(self):
        """
        Mycroft Stop Function
        """
        pass


def create_skill():
    """
    Mycroft Create Skill Function
    """
    return MapNavigationPlacesSkill()

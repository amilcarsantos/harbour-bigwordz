/*
  Copyright (C) 2014 Amilcar Santos
  Contact: Amilcar Santos <amilcar.santos@gmail.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Amilcar Santos nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"
import "pages/util/Persistence.js" as Persistence

ApplicationWindow
{
	id: window

	property string version: "0.2"
	property string appname: "Big Wordz"
	property string appicon: "qrc:/harbour-bigwordz.png"
	property string appurl:  "https://github.com/amilcarsantos/harbour-bigwordz"

	property string currentText

	// persistente options
	property string colorScheme
	property string customSchemeColors
	property bool useSensors
	property bool tap2toggle
	property bool startWithStoredWord

	signal initialUpdate

	function textColor() {
		if (colorScheme == "custom") {
			return customSchemeColors.substring(0,7)
		}
		if (colorScheme == "blackWhite") {
			return 'white'
		}
		return Theme.highlightColor
	}

	function backColor() {
		if (colorScheme == "custom") {
			return customSchemeColors.substring(7)
		}
		if (colorScheme == "blackWhite") {
			return 'black'
		}
		return 'transparent'
	}

	function storedWords() {
		var words = []
		for (var index = 0; index < storedWordsModel.count; index++) {
			words.push(storedWordsModel.get(index).text)
		}
		return words
	}

	ListModel {
		id: storedWordsModel

		function storeCurrentText() {
			if (count > 0 && get(0).text === currentText) {
				// already stored has latest, nothing to do
				return
			}
			// move to the top if alredy exists
			for (var index = 1; index < count; index++) {
				if (get(index).text === currentText) {
					move(index, 0, 1)
					Persistence.updateStoredWordUsage(currentText)
					return
				}
			}
			insert(0, { "text": currentText })
			// insert in DB
			Persistence.persistStoredWord(currentText)
			return
		}

		function removeStoredWord(word) {
			for (var index = 0; index < count; index++) {
				if (get(index).text === word) {
					remove(index)
					Persistence.removeStoredWord(word)
					return 1
				}
			}
			return 0
		}

		function removeAll() {
			clear()
			Persistence.removeAllStoredWords()
		}
	}

	initialPage: Component { MainPage { } }
	cover: Component { CoverPage { } }

	Component.onCompleted: {
		// init Persistence
		Persistence.initialize()
		colorScheme = Persistence.setting("colorScheme", "theme")
		customSchemeColors = Persistence.setting("customSchemeColors", "")
		tap2toggle = Persistence.settingBool("tap2toggle", false)
		useSensors = Persistence.settingBool("useSensors", false)
		startWithStoredWord = Persistence.settingBool("startWithStoredWord", false)
		Persistence.populateStoredWords(storedWordsModel)

		if (startWithStoredWord && storedWordsModel.count > 0) {
			currentText = storedWordsModel.get(0).text
		}
		if (currentText === "") {
			currentText = "Hello"	// fallback to 'Hello'
		}
		initialUpdate()
	}

	Component.onDestruction: {
		Persistence.setSetting("colorScheme", colorScheme)
		Persistence.setSetting("customSchemeColors", customSchemeColors)
		Persistence.setSetting("tap2toggle", tap2toggle)
		Persistence.setSetting("useSensors", useSensors)
		Persistence.setSetting("startWithStoredWord", startWithStoredWord)
	}
}



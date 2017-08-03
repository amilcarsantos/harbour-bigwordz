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

	property string version: "0.8"
	property string appname: "Big Wordz"
	property string appicon: "image://theme/harbour-bigwordz"
	property string appurl:  "https://github.com/amilcarsantos/harbour-bigwordz"

	property string currentText
	property string currentMarkupText
	property string currentMarkupBgText

	property bool _saveColors: false
	property bool _set: false
	// persistente options
	property string colorScheme
	property string customSchemeColors
	property bool useSensors
	property int sensorsSensitivity
	property bool tap2toggle
	property bool startWithStoredWord
	property bool autoStoreWord
	property bool markupWord

	signal initialUpdate
	signal onForceTextUpdate

	function textColor() {
		if (colorScheme == "custom" || colorScheme == "customGrad") {
			return customSchemeColorAt(0)
		}
		if (colorScheme == "blackWhite") {
			return 'white'
		}
		return Theme.highlightColor
	}

	function backColor() {
		if (colorScheme == "custom") {
			return customSchemeColorAt(1)
		}
		if (colorScheme == "customGrad") {
			var direction = customSchemeColors.substring(22);
			if (direction === '1' || direction === '2') {
				return customSchemeColorAt(2);
			}
			return customSchemeColorAt(1);
		}
		if (colorScheme == "blackWhite") {
			return 'black'
		}
		return 'transparent'
	}

	function backColor2() {
		if (colorScheme == "customGrad") {
			var direction = customSchemeColors.substring(22);
			if (direction === '1' || direction === '2') {
				return customSchemeColorAt(1);
			}
			return customSchemeColorAt(2)
		}
		return 'black'
	}

	function customGradRotation() {
		if (colorScheme == "customGrad") {
			var direction = customSchemeColors.substring(22);
			if (direction === '1' || direction === '3') {
				return 90;
			}
			return 0;
		}
		return -1;
	}

	function customSchemeColorAt(index) {
		return customSchemeColors.substring(index * 7, (index + 1) * 7)
	}

	function storedWords() {
		var words = []
		for (var index = 0; index < storedWordsModel.count; index++) {
			words.push(storedWordsModel.get(index).text)
		}
		return words
	}

	function favoriteWords() {
		var words = []
		for (var index = 0; index < favoriteWordsModel.count; index++) {
			words.push(favoriteWordsModel.get(index).text)
		}
		return words
	}

	function forceTextUpdate(text) {
		currentText = text
		onForceTextUpdate()
	}

	function pop2MainPage() {
		if (pageStack.depth > 1) {
			pageStack.pop(pageStack[0], PageStackAction.Immediate)
		}
	}

	ListModel {
		id: storedWordsModel

		function storeCurrentText() {
			if ((count > 0 && get(0).text === currentText) || currentText.trim().length === 0) {
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

		function lastStoredWord() {
			if (storedWordsModel.count > 0) {
				return storedWordsModel.get(0).text
			}
			return ""
		}
	}

	ListModel {
		id: favoriteWordsModel

		function addFavoriteWord(word) {
			append({ "text": word })
			Persistence.addFavoriteWord(word)
		}
		function removeFavoriteWord(word) {
			for (var index = 0; index < count; index++) {
				if (get(index).text === word) {
					remove(index)
					Persistence.removeFavoriteWord(word)
					return 1
				}
			}
			return 0
		}
		function isFavoriteWord(word) {
			for (var index = 0; index < count; index++) {
				if (get(index).text === word) {
					return 1
				}
			}
			return 0
		}
		function removeAll() {
			clear()
			Persistence.removeAllFavoriteWords()
		}
	}

	initialPage: Component { MainPage { } }
	cover: Component { CoverPage { } }

	Component.onCompleted: {
		// init Persistence
		Persistence.initialize()
//		colorScheme = Persistence.setting("colorScheme", "theme")
		colorScheme = Persistence.setting("colorScheme", "blackWhite") // "je suis charlie" edition
		customSchemeColors = Persistence.setting("customSchemeColors", "")
		tap2toggle = Persistence.settingBool("tap2toggle", false)
		useSensors = Persistence.settingBool("useSensors", false)
		sensorsSensitivity = Persistence.settingInt("sensorsSensitivity", 6)
		startWithStoredWord = Persistence.settingBool("startWithStoredWord", false)
		autoStoreWord = Persistence.settingBool("autoStoreWord", true)
		markupWord = Persistence.settingBool("markupWord", true)
		Persistence.populateStoredWords(storedWordsModel)
		Persistence.populateFavoriteWords(favoriteWordsModel)

		if (startWithStoredWord) {
			currentText = storedWordsModel.lastStoredWord()
		}
		if (currentText === "") {
            currentText = "#rnd_ltrs#Hello## :)"	// fallback to 'Hello'
		}
		initialUpdate()
		_set = true
	}

	Component.onDestruction: {
		if (_saveColors) {
			Persistence.setSetting("colorScheme", colorScheme)
			Persistence.setSetting("customSchemeColors", customSchemeColors)
		}
	}

	onColorSchemeChanged: _saveColors = true;
	onCustomSchemeColorsChanged: _saveColors = true;
	onTap2toggleChanged: {
		if (_set) Persistence.setSetting("tap2toggle", tap2toggle)
	}
	onUseSensorsChanged: {
		if (_set) Persistence.setSetting("useSensors", useSensors)
	}
	onSensorsSensitivityChanged: {
		if (_set) Persistence.setSetting("sensorsSensitivity", sensorsSensitivity)
	}
	onStartWithStoredWordChanged: {
		if (_set) Persistence.setSetting("startWithStoredWord", startWithStoredWord)
	}
	onAutoStoreWordChanged: {
		if (_set) Persistence.setSetting("autoStoreWord", autoStoreWord)
	}
	onMarkupWordChanged: {
		if (_set) Persistence.setSetting("markupWord", markupWord)
	}
}

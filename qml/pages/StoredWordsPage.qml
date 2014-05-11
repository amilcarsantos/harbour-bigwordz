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


Page {
	id: storedWordsPage

	allowedOrientations: Orientation.All

	property string searchString: ""

	signal textChanged

	onSearchStringChanged: {
		listModel.update()
	}

	Component.onCompleted: {
		listModel.update()
	}

	Column {
		id: headerContainer
		width: storedWordsPage.width

		PageHeader {
			title: qsTr("Stored words")
		}

		SearchField {
			id: searchField
			width: parent.width

			Binding {
				target: storedWordsPage
				property: "searchString"
				value: searchField.text.toLowerCase().trim()
			}

			Keys.onReturnPressed: storedWordsPage.focus = true
			Keys.onEnterPressed: storedWordsPage.focus = true
		}
	}

	SilicaListView {
		id: listView
		model: listModel
		anchors.fill: parent
		header: Item {
			id: header
			width: headerContainer.width
			height: headerContainer.height
			Component.onCompleted: headerContainer.parent = header
		}

		PullDownMenu {
			MenuItem {
				function restoreControls() {
					listView.enabled = true
				}
				enabled: storedWordsModel.count > 0
				text: qsTr("Delete all")
				onClicked: {
					// 1st) block user iteraction with listview
					listView.enabled = false;
					// start remorse action
					remorsePopup.execute(qsTr("Deleting all stored words"), function() {
						while (listModel.count > 0) {
							listModel.remove(listModel.count - 1)
						}
						storedWordsModel.removeAll()
						favoriteWordsModel.removeAll()
						restoreControls()
					})
					remorsePopup.canceled.connect(restoreControls)
				}
			}
//			MenuItem {
//				enabled: storedWordsModel.count > 0
//				text: qsTr("Order by: Last usage")
//				onClicked: {
//				}
//			}
		}

		delegate: ListItem {
			id: delegate
			menu: contextMenu

			ListView.onRemove: animateRemoval(delegate)

			Label {
				id: label
				x: searchField.textLeftMargin
				width: parent.width - x - Theme.paddingMedium
				anchors.verticalCenter: parent.verticalCenter
				color: searchString.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
												: (highlighted ? Theme.highlightColor : Theme.primaryColor)
				textFormat: Text.StyledText
				text: formatText(model.text)

				function formatText(modelText) {
					if (modelText === undefined) {
						return ''
					}

					if (modelText.indexOf('<') >= 0) {
						modelText = modelText.replace('<', '&lt;')
					}

					if (searchString) {
						return Theme.highlightText(modelText, searchString, Theme.highlightColor)
					}
					return modelText
				}
			}
			Image {
				id: favIcon
				anchors.top: label.top
				anchors.right: label.right
				source: "image://theme/icon-s-favorite"
				opacity: 0.7
				visible: model.isFavorite
			}
			OpacityRampEffect {
				sourceItem: label
				offset: 0.3
				slope: 1.4
			}
			function addFavoriteWord() {
				favoriteWordsModel.addFavoriteWord(model.text);
				listModel.setProperty(model.index, "isFavorite", true)
			}
			function removeFavoriteWord() {
				favoriteWordsModel.removeFavoriteWord(model.text);
				listModel.setProperty(model.index, "isFavorite", false)
			}
			function deleteWord() {
				remorseAction(qsTr("Deleting"), function() {
					storedWordsModel.removeStoredWord(model.text)
					if (model.isFavorite) {
						favoriteWordsModel.removeFavoriteWord(model.text)
					}
					listModel.remove(index)
				})
			}

			onClicked: {
				window.currentText = model.text
				storedWordsModel.storeCurrentText()
				textChanged()
				pageStack.pop()
			}

			Component {
				id: contextMenu
				ContextMenu {
					id: itemInfo
					property bool isFavorite: false
					onActiveChanged: {
//						console.log("model.isFavorite " + model.isFavorite )
						if (active) {
							isFavorite = model.isFavorite
						}
					}
					MenuItem {
						text: itemInfo.isFavorite ? qsTr("Remove from favorites") : qsTr("Add to favorites")
						enabled: favoriteWordsModel.count < 16 || itemInfo.isFavorite
						onClicked: {
							if (itemInfo.isFavorite) {
								removeFavoriteWord()
							} else {
								addFavoriteWord()
							}
						}
					}
					MenuItem {
						text: qsTr("Delete")
						onClicked: deleteWord()
					} 
				}
			}
		}
		VerticalScrollDecorator {}
	}

	RemorsePopup {
		id: remorsePopup
	}

	ListModel {
		id: listModel

		function update() {
			var words = window.storedWords()
			var favWords = window.favoriteWords()

			var filteredWords = words.filter(function (word) {
				return word.toLowerCase().indexOf(searchString) !== -1
			})
			while (count > filteredWords.length) {
				remove(filteredWords.length)
			}
			for (var index = 0; index < filteredWords.length; index++) {
				var text = filteredWords[index]
				var isFavorite = false
				for (var f = 0; f < favWords.length; f++) {
					if (text === favWords[f]) {
						isFavorite = true
// TODO					favWords.remove(f)
						break;
					}
				}

				if (index < count) {
					setProperty(index, "text", text)
					setProperty(index, "isFavorite", isFavorite)
				} else {
					append({
						"text": text,
						"isFavorite" : isFavorite
					})
				}
			}
		}
	}
}

/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Rectangle
{
	id: control
	width: parent.width
    height: Maui.Style.toolBarHeight
	property alias listView : tagsList
	property alias count : tagsList.count
	property bool editMode : false
	property bool allowEditMode : false
	property alias list : tagsList.list
	
	signal addClicked()
	signal tagRemovedClicked(int index)
	signal tagClicked(string tag)
	signal tagsEdited(var tags)
	
	color: "transparent"  
	
	RowLayout
	{
		anchors.fill: parent
		spacing: 0
		
		RowLayout
		{
			Layout.fillHeight: true
			Layout.fillWidth: true
			visible: !editMode
			spacing: 0
			
			ToolButton
			{
				Layout.alignment: Qt.AlignLeft
				visible: allowEditMode
				icon.name: "list-add"
				onClicked: addClicked()
				icon.color: control.Kirigami.Theme.textColor
			}
			
			TagList
			{
				id: tagsList
				Layout.leftMargin: Maui.Style.space.medium
				Layout.alignment: Qt.AlignCenter
				Layout.fillHeight: true
				Layout.fillWidth: true
				showPlaceHolder: allowEditMode
				showDeleteIcon: allowEditMode
				onTagRemoved: tagRemovedClicked(index)
				onTagClicked: control.tagClicked(tagsList.list.get(index).tag)
				Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
				Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor					
				MouseArea
				{
					anchors.fill: parent
					z: tagsList.z -1
					propagateComposedEvents: true
					onClicked: if(allowEditMode) goEditMode()
				}
			}
		}
		
		Maui.TextField
		{
			id: editTagsEntry
			visible: control.editMode
			Layout.fillHeight: true
			Layout.fillWidth:true
			horizontalAlignment: Text.AlignLeft
			verticalAlignment:  Text.AlignVCenter
			selectByMouse: !Kirigami.Settings.isMobile
			focus: true
			wrapMode: TextEdit.NoWrap
			color: Kirigami.Theme.textColor
			selectionColor: Kirigami.Theme.highlightColor
			selectedTextColor: Kirigami.Theme.highlightedTextColor
			onAccepted: control.saveTags()
			
			actions.data: ToolButton
			{
				Layout.alignment: Qt.AlignLeft
				icon.name: "checkbox"
				onClicked: editTagsEntry.accepted()
				
			}
		}		
	}
	
	function clear()
	{
		//         tagsList.model.clear()
	}
	
	function goEditMode()
	{
		var currentTags = []
		for(var i = 0 ; i < tagsList.count; i++)
			currentTags.push(list.get(i).tag)
			
			editTagsEntry.text = currentTags.join(", ")
			editMode = true
			editTagsEntry.forceActiveFocus()
	}
	
	function saveTags()
	{
		control.tagsEdited(control.getTags())
		editMode = false
	}
	
	function getTags()
	{
		if(!editTagsEntry.text.length > 0)
			return
			
		var tags = []
		if(editTagsEntry.text.trim().length > 0)
		{
			var list = editTagsEntry.text.split(",")
			
			if(list.length > 0)
				for(var i in list)
					tags.push(list[i].trim())
		}
		
		return tags
	}
}

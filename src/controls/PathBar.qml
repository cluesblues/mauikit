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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Item
{
	id: control    
	
	height: iconSizes.big
	
	property string url : ""
	property bool pathEntry: false
	property alias list : _pathList
	property alias model : _pathModel
	property alias item : _loader.item
	
	signal pathChanged(string path)
	signal homeClicked()
	signal placeClicked(string path)
	
	onUrlChanged: append()
	
	Kirigami.Theme.colorSet: Kirigami.Theme.View
	Kirigami.Theme.inherit: false
	
	Rectangle
	{
		id: pathBarBG
		anchors.fill: parent
		
		//         z: -1
		color: pathEntry ? Kirigami.Theme.backgroundColor : Kirigami.Theme.backgroundColor
		radius: radiusV
		opacity: 1
		border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
		border.width: unit
	}
	
	Loader
	{
		id: _loader        
		anchors.fill: parent
		sourceComponent: pathEntry ? _pathEntryComponent : _pathCrumbsComponent
		
		onLoaded:
		{
			if(sourceComponent === _pathCrumbsComponent)
				control.append()
		}
	}
	
	Maui.BaseModel
	{
		id: _pathModel
		list: _pathList
	}
	
	Maui.PathList
	{
		id: _pathList
	}
	
	Component
	{
		id: _pathEntryComponent
		RowLayout
		{
			anchors.fill:  parent
			
			Maui.TextField
			{
				id: entry
				text: control.url
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.leftMargin: contentMargins
				Layout.alignment: Qt.AlignVCenter
				Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
				Kirigami.Theme.backgroundColor: "transparent"
// 				Kirigami.Theme.borderColor: "transparent"
				horizontalAlignment: Qt.AlignLeft
				onAccepted:
				{
					pathChanged(text)
					showEntryBar()
				}
				background: Rectangle
				{
					color: "transparent"
				}
			}
			
			Item
			{
				Layout.fillHeight: true
				Layout.leftMargin: space.small
				Layout.rightMargin: space.small
				width: iconSize
				
				ToolButton
				{
					anchors.centerIn: parent
					icon.name: "go-next"
					icon.color: control.Kirigami.Theme.textColor
					onClicked:
					{
						pathChanged(entry.text)
						showEntryBar()
					}
				}
			}
		}
	}
	
	Component
	{
		id: _pathCrumbsComponent
		
		RowLayout
		{
			anchors.fill: parent
			spacing: 0
			property alias listView: _listView
			clip: true
			
			Item
			{
				Layout.fillHeight: true
				Layout.leftMargin: space.small
				Layout.rightMargin: space.small
				width: iconSize
				
				ToolButton
				{
					anchors.centerIn: parent
					icon.name: "go-home"
					flat: true
					icon.color: control.Kirigami.Theme.textColor                
					onClicked: homeClicked()
				}
			}
			
			Kirigami.Separator
			{
				Layout.fillHeight: true
				color: pathBarBG.border.color
			}
		
			
			ListView
			{
				id: _listView
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				orientation: ListView.Horizontal
				clip: true
				spacing: 0
				
				focus: true
				interactive: true
				boundsBehavior: isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds
				
				model: _pathModel
				
				delegate: PathBarDelegate
				{
					id: delegate
					height: control.height - (unit*2)
					width: iconSizes.big * 3
					Connections
					{
						target: delegate
						onClicked:
						{
							_listView.currentIndex = index
							placeClicked(_pathList.get(index).path)
						}
					}
				}
				
				MouseArea
				{
					anchors.fill: parent
					onClicked: showEntryBar()
					z: -1
				}				
			}
			
			Item
			{
				Layout.fillHeight: true
				Layout.leftMargin: space.small
				Layout.rightMargin: space.small
				width: iconSize
				ToolButton
				{
					anchors.centerIn: parent
					flat: true
					icon.name: "filename-space-amarok"
					icon.color: control.Kirigami.Theme.textColor                
					onClicked: showEntryBar()
				}
			}
			
			//        MouseArea
			//        {
			//            anchors.fill: parent
			//            propagateComposedEvents: true
			//            onClicked: showEntryBar()
			//        }
			
			
			
		}
	}
	
	Component.onCompleted: control.append()	
	
	function append()
	{
		_pathList.path = control.url
		
		if(_loader.sourceComponent !== _pathCrumbsComponent)
			return
			
		_loader.item.listView.currentIndex = _loader.item.listView.count-1
		_loader.item.listView.positionViewAtEnd()
	}
	
	function showEntryBar()
	{
		control.pathEntry = !control.pathEntry
	}
}

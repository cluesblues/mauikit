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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Maui.AbstractSideBar
{
	id: control
	implicitWidth: privateProperties.isCollapsed && collapsed && collapsible  ? collapsedSize : preferredWidth
	width: implicitWidth
	modal: false
	position: 1
	interactive: false
	
	default property list<Action> actions 
		property int count : _listBrowser.count
		
		
		property alias currentIndex: _listBrowser.currentIndex
		
		property int iconSize : Maui.Style.iconSizes.medium
		property bool showLabels: control.width > collapsedSize
		
		property QtObject privateProperties : QtObject
		{
			property bool isCollapsed: control.collapsed
		}
		
		signal itemClicked(int index)
		signal itemRightClicked(int index)
		
		onModalChanged: visible = true
		visible: true
		
		onCollapsedChanged :
		{
			if(!collapsible)
				return
				
				if(!collapsed && modal)
				{
					modal = false
					
				}
				
				if(!modal && !collapsed)
				{
					privateProperties.isCollapsed = false
				}
				
				if(collapsed && !modal)
				{
					privateProperties.isCollapsed = true
				}
		}
		
		ColumnLayout
		{
			id: _content
			anchors.fill: parent
			spacing: 0
			
			Maui.ListBrowser
			{
				id: _listBrowser
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.topMargin: Maui.Style.space.tiny
				Layout.bottomMargin: Maui.Style.space.tiny
				Layout.margins: Maui.Style.unit
				listView.flickableDirection: Flickable.VerticalFlick
				model: control.actions
				verticalScrollBarPolicy:  Qt.ScrollBarAlwaysOff  //this make sthe app crash
				
				delegate: Maui.ListDelegate
				{
					id: itemDelegate
					action : modelData
					iconSize: control.iconSize
					labelVisible: control.showLabels
					iconName: action.icon.name
					label: action.text
					leftPadding:  Maui.Style.space.tiny
					rightPadding:  Maui.Style.space.tiny
					
					Connections
					{
						target: itemDelegate
						onClicked:
						{
							control.currentIndex = index
							target.action.triggered()
							control.itemClicked(index)
						}
						
						onRightClicked:
						{
							control.currentIndex = index
							control.itemRightClicked(index)
						}
						
						onPressAndHold:
						{
							control.currentIndex = index
							control.itemRightClicked(index)
						}
					}
				}
			}
			
			MouseArea
			{
				id: _handle
				visible: collapsible && collapsed
				Layout.preferredHeight: Maui.Style.toolBarHeight
				Layout.fillWidth: true
				hoverEnabled: true
				preventStealing: true
				propagateComposedEvents: false
				property int startX
				property int startY
				
				Rectangle
				{
					anchors.fill: parent
					color:  _handle.containsMouse || _handle.containsPress ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2) : "transparent"
					
					Kirigami.Separator
					{
						anchors
						{
							left: parent.left
							right: parent.right
							top: parent.top
						}
						height: Maui.Style.unit
					}
					
					Kirigami.Icon
					{
						source: privateProperties.isCollapsed ? "sidebar-expand" : "sidebar-collapse"
						color:  _handle.containsMouse || _handle.containsPress ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
						anchors.centerIn: parent
						width: Maui.Style.iconSizes.medium
						height: width
					}
				}
				
				onPositionChanged:
				{
					if (!pressed || !control.collapsible || !control.collapsed || !Kirigami.Settings.isMobile)
						return
						
						if(mouse.x > control.collapsedSize)
						{
							expand()
						}
						
						mouse.accepted = true
				}
				
				onPressed:
				{
					startY = mouse.y
					startX = mouse.x
					mouse.accepted = true
				}
				
				onReleased:
				{
					if(!control.collapsible)
						return
						
						if(mouse.x > control.width)
							return
							
							if(privateProperties.isCollapsed)
								expand()
								else
									collapse()
									
									mouse.accepted = true
				}
			}
		}
		
		MouseArea
		{
			z: control.modal ? applicationWindow().overlay.z + (control.position > 0 ? +1 : -1) : control.background.parent.z + 1
			preventStealing: true
			anchors.horizontalCenter: parent.right
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			visible: Kirigami.Settings.isMobile
			enabled: control.collapsed && visible
			width: Maui.Style.space.large
			property int startX
			property int startY
			
			onPressed:
			{
				startY = mouse.y
				startX = mouse.x
				mouse.accepted = true
			}
			
			onPositionChanged:
			{
				if (!pressed || !control.collapsible || !control.collapsed || !Kirigami.Settings.isMobile)
					return
					
					if(mouse.x > control.collapsedSize)
					{
						expand()
					}else
					{
						collapse()
					}
					
					mouse.accepted = true
			}
		}
		
		function collapse()
		{
			if(collapsible && !privateProperties.isCollapsed)
			{
				modal = false
				privateProperties.isCollapsed  = true
			}
		}
		
		function expand()
		{
			if(collapsible && privateProperties.isCollapsed)
			{
				modal = true
				privateProperties.isCollapsed = false
			}
		}
}

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

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.12

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

import "private"

Maui.Page
{
	id: control
	
	property url currentPath
	onCurrentPathChanged:
	{
		if(control.browserView)
			control.browserView.path = control.currentPath
	}
	
	property alias viewType : _viewTypeGroup.currentIndex
	
	property int thumbnailsSize : Maui.Style.iconSizes.large * 1.7
	
	property var indexHistory : []
	
	property bool isCopy : false
	property bool isCut : false
	
	property bool group : false
	
	//group properties from the browser since the browser views are loaded async and
	//their properties can not be accesed inmediately, so they are stored here and then when completed they are set
	property alias settings : _settings
	BrowserSettings {id: _settings }
	
	property alias selectionBar : _selectionBar
	property alias browserView : _browserList.currentItem
	readonly property Maui.FMList currentFMList : browserView.currentFMList
	readonly property Maui.BaseModel currentFMModel : browserView.currentFMModel
	
	property alias previewer : previewer
	property alias menu : browserMenu.contentData
	property alias itemMenu: itemMenu
	property alias dialog : dialogLoader.item
	
	signal itemClicked(int index)
	signal itemDoubleClicked(int index)
	signal itemRightClicked(int index)
	signal itemLeftEmblemClicked(int index)
	signal itemRightEmblemClicked(int index)
	signal rightClicked()
	signal keyPress(var event)
	
	Kirigami.Theme.colorSet: Kirigami.Theme.View
	Kirigami.Theme.inherit: false
	
	onGoBackTriggered: control.goBack()
	onGoForwardTriggered: control.goNext()
	
	focus: true
	
	flickable: browserView.currentView.flickable
	
	footBar.visible: Maui.FM.loadSettings("StatusBar", "SETTINGS", false) == "true" ||  String(control.currentPath).startsWith("trash:/")
	
	footBar.leftSretch: false
	footBar.middleContent: Maui.TextField
	{
		id: _filterField
		Layout.fillWidth: true
		visible: control.currentFMList.count > 0
		placeholderText: String("Filter %1 files").arg(control.currentFMList ? control.currentFMList.count : 0)
		onAccepted: control.browserView.filter = text
		onCleared: control.browserView.filter = ""
		inputMethodHints: Qt.ImhNoAutoUppercase
		onTextChanged:
		{
			if(control.currentFMList.count < 50)
				_filterField.accepted()
		}
		Keys.enabled: true
		Keys.onPressed:
		{
			// Shortcut for clearing selection
			if(event.key == Qt.Key_Up)
			{
				// 				_filterField.clear()
				// 				footBar.visible = false
				browserView.currentView.forceActiveFocus()
			}
		}
	}
	
	footBar.rightContent: [
	
	ToolButton
	{
		icon.name: "zoom-in"
		onClicked: zoomIn()
	},
	
	ToolButton
	{
		icon.name: "zoom-out"
		onClicked: zoomOut()
	},
	
	ToolButton
	{
		visible: String(control.currentPath).startsWith("trash:/")
		icon.name: "trash-empty"
		text: qsTr("Empty Trash")
		onClicked: Maui.FM.emptyTrash()
	}
	]
	
	footerPositioning: ListView.InlineFooter
	headBar.position: Kirigami.Settings.isMobile ? ToolBar.Footer : ToolBar.Header
	
	headBar.rightContent:[
	
	ToolButton
	{
		icon.name: "item-select"
		checkable: true
		checked: settings.selectionMode
		onClicked: settings.selectionMode = !settings.selectionMode
		onPressAndHold: control.selectAll()
	},
	
	Maui.ToolButtonMenu
	{
		icon.name: "view-sort"
		
		MenuItem
		{
			text: qsTr("Show Folders First")
			checked: control.currentFMList.foldersFirst
			checkable: true
			onTriggered: control.currentFMList.foldersFirst = !control.currentFMList.foldersFirst
		}
		
		MenuSeparator {}
		
		MenuItem
		{
			text: qsTr("Type")
			checked: control.currentFMList.sortBy === Maui.FMList.MIME
			checkable: true
			onTriggered: control.currentFMList.sortBy = Maui.FMList.MIME
			autoExclusive: true
		}
		
		MenuItem
		{
			text: qsTr("Date")
			checked: control.currentFMList.sortBy === Maui.FMList.DATE
			checkable: true
			onTriggered: control.currentFMList.sortBy = Maui.FMList.DATE
			autoExclusive: true
		}
		
		MenuItem
		{
			text: qsTr("Modified")
			checkable: true
			checked: control.currentFMList.sortBy === Maui.FMList.MODIFIED
			onTriggered: control.currentFMList.sortBy = Maui.FMList.MODIFIED
			autoExclusive: true
		}
		
		MenuItem
		{
			text: qsTr("Size")
			checkable: true
			checked: control.currentFMList.sortBy === Maui.FMList.SIZE
			onTriggered: control.currentFMList.sortBy = Maui.FMList.SIZE
			autoExclusive: true
		}
		
		MenuItem
		{
			text: qsTr("Name")
			checkable: true
			checked: control.currentFMList.sortBy === Maui.FMList.LABEL
			onTriggered: control.currentFMList.sortBy = Maui.FMList.LABEL
			autoExclusive: true
		}
		
		MenuSeparator{}
		
		MenuItem
		{
			id: groupAction
			text: qsTr("Group")
			checkable: true
			checked: control.group
			onTriggered:
			{
				control.group = !control.group
				if(control.group)
					control.groupBy()
					else
						browserView.currentView.section.property = ""
			}
		}
		
	},
	
	ToolButton
	{
		id: _optionsButton
		icon.name: "overflow-menu"
		enabled: currentFMList.pathType !== Maui.FMList.TAGS_PATH && currentFMList.pathType !== Maui.FMList.TRASH_PATH && currentFMList.pathType !== Maui.FMList.APPS_PATH
		onClicked:
		{
			if(browserMenu.visible)
				browserMenu.close()
				else
					browserMenu.show(_optionsButton, 0, height)
		}
		checked: browserMenu.visible
		checkable: false
	}
	]
	
	headBar.leftContent: [
	ToolButton
	{
		icon.name: "go-previous"
		onClicked: control.goBack()
	},
	
	ToolButton
	{
		icon.name: "go-next"
		onClicked: control.goNext()
	},
	
	Maui.ToolActions
	{
		id: _viewTypeGroup
		
		currentIndex: Maui.FMList.LIST_VIEW
		onCurrentIndexChanged:
		{
			if(browserView)
				browserView.viewType = currentIndex             
		}
		
		Action
		{
			icon.name: "view-list-icons"
			text: qsTr("Grid") 
			shortcut: "Ctrl+G"
		}
		
		Action
		{
			icon.name: "view-list-details"
			text: qsTr("List")
			shortcut: "Ctrl+L"			
		}
		
		Action
		{
			icon.name: "view-file-columns"
			text: qsTr("Columns")
			shortcut: "Ctrl+M"			
		}
	}
	]
	
	Loader { id: dialogLoader }
	
	Component
	{
		id: removeDialogComponent
		
		Maui.Dialog
		{
			property var urls: []
			
			title:  "Removing %1 files".arg(urls.length)
			message: Maui.Handy.isAndroid ?  qsTr("This action will completely remove your files from your system. This action can not be undone.") : qsTr("You can move the file to the trash or delete it completely from your system. Which one do you prefer?")
			rejectButton.text: qsTr("Delete")
			acceptButton.text: qsTr("Trash")
			acceptButton.visible: Maui.Handy.isLinux
			page.padding: Maui.Style.space.huge
			
			onRejected:
			{
				if(control.selectionBar.visible)
				{
					control.selectionBar.animate()
					control.clearSelection()
				}
				
				for(var i in urls)
					Maui.FM.removeFile(urls[i])
					
					close()
			}
			
			onAccepted:
			{
				if(control.selectionBar.visible)
				{
					control.selectionBar.animate()
					control.clearSelection()
				}
				
				for(var i in urls)
					Maui.FM.moveToTrash(urls[i])
					close()
			}
		}
	}
	
	Component
	{
		id: newFolderDialogComponent
		
		Maui.NewDialog
		{
			title: qsTr("New Folder")
			message: qsTr("Create a new folder with a custom name")
			acceptButton.text: qsTr("Create")
			onFinished: control.currentFMList.createDir(text)
			rejectButton.visible: false
			textEntry.placeholderText: qsTr("Folder name")
		}
	}
	
	Component
	{
		id: newFileDialogComponent
		
		Maui.NewDialog
		{
			title: qsTr("New File")
			message: qsTr("Create a new file with a custom name and extension")
			acceptButton.text: qsTr("Create")
			onFinished: Maui.FM.createFile(control.currentPath, text)
			rejectButton.visible: false
			textEntry.placeholderText: qsTr("Filename")
		}
	}
	
	Component
	{
		id: renameDialogComponent
		Maui.NewDialog
		{
			title: qsTr("Rename File")
			message: qsTr("Rename a file or folder")
			textEntry.text: itemMenu.item.label
			textEntry.placeholderText: qsTr("New name")
			onFinished: Maui.FM.rename(itemMenu.item.path, textEntry.text)
			onRejected: close()
			acceptText: qsTr("Rename")
			rejectText: qsTr("Cancel")
		}
	}
	
	Component
	{
		id: shareDialogComponent
		MauiLab.ShareDialog {}
	}
	
	Component
	{
		id: tagsDialogComponent
		Maui.TagsDialog
		{
			taglist.strict: false
			onTagsReady:
			{
				composerList.updateToUrls(tags)
				if(control.previewer.visible)
					control.previewer.tagBar.list.refresh()
			}
		}
	}
	
	Maui.FilePreviewer
	{
		id: previewer
		onShareButtonClicked: control.shareFiles([url])
	}
	
	BrowserMenu { id: browserMenu }
	
	FileMenu
	{
		id: itemMenu
		width: Maui.Style.unit *200
		onBookmarkClicked: control.bookmarkFolder([item.path])
		onCopyClicked:
		{
			if(item)
				control.copy([item.path])
		}
		
		onCutClicked:
		{
			if(item)
				control.cut([item.path])
		}
		
		onTagsClicked:
		{
			if(item)
			{
				dialogLoader.sourceComponent = tagsDialogComponent
				dialog.composerList.urls = [item.path]
				dialog.open()
			}
		}
		
		onRenameClicked:
		{
			dialogLoader.sourceComponent = renameDialogComponent
			dialog.open()
		}
		
		onRemoveClicked:
		{
			console.log("REMOVE", item.path)
			control.remove([item.path])
		}
		
		onShareClicked: control.shareFiles([item.path])
	}
	
	Connections
	{
		enabled: browserView.currentView != null
		target: browserView.currentView
		
		onKeyPress:
		{
			const index = browserView.currentView.currentIndex
			const item = control.currentFMList.get(index)
			
			// Shortcuts for refreshing
			if((event.key == Qt.Key_F5))
			{
				control.currentFMList.refresh()
			}
			
			// Shortcuts for selecting file
			if((event.key == Qt.Key_A) && (event.modifiers & Qt.ControlModifier))
			{
				control.selectAll()
			}
			
			if(event.key == Qt.Key_S)
			{
				if(control.selectionBar.contains(item.path))
				{
					control.selectionBar.removeAtUri(item.path)
				}else
				{
					control.addToSelection(item)
				}
			}
			
			if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
			{
				if(control.selectionBar.contains(item.path))
				{
					control.selectionBar.removeAtUri(item.path)
				}else
				{
					control.addToSelection(item)
				}
			}
			
			// Shortcut for pasting an item
			if((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier))
			{
				control.paste(Maui.Handy.getClipboard().urls)
			}
			
			// Shortcut for cutting an item
			if((event.key == Qt.Key_X) && (event.modifiers & Qt.ControlModifier))
			{
				var urls = []
				if(control.selectionBar.count > 0)
				{
					urls = control.selectionBar.uris
				}
				else
				{
					urls = [item.path]
				}
				control.cut(urls)
			}
			
			// Shortcut for copying an item
			if((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier))
			{
				var urls = []
				if(control.selectionBar.count > 0)
				{
					urls = control.selectionBar.uris
				}
				else
				{
					urls = [item.path]
				}
				control.copy(urls)
			}
			
			// Shortcut for removing an item
			if(event.key == Qt.Key_Delete)
			{
				var urls = []
				if(control.selectionBar.count > 0)
				{
					urls = control.selectionBar.uris
				}
				else
				{
					urls = [item.path]
				}
				control.remove(urls)
			}
			
			// Shortcut for opening new tab
			if((event.key == Qt.Key_T) && (event.modifiers & Qt.ControlModifier))
			{
				control.openTab(currentPath)
			}
			
			// Shortcut for closing tab
			if((event.key == Qt.Key_W) && (event.modifiers & Qt.ControlModifier))
			{
				if(tabsBar.count > 1)
					control.closeTab(tabsBar.currentIndex)
			}
			
			// Shortcut for opening files in new tab , previewing or launching
			if((event.key == Qt.Key_Return) && (event.modifiers & Qt.ControlModifier))
			{
				if(item.isdir == "true")
					control.openTab(item.path)
					
			}else if((event.key == Qt.Key_Return) && (event.modifiers & Qt.AltModifier))
			{
				control.previewer.show(currentFMModel, index)
			}else if(event.key == Qt.Key_Return)
			{
				indexHistory.push(index)
				control.openItem(index)				
			}
			
			// Shortcut for going back in browsing history
			if(event.key == Qt.Key_Backspace || event.key == Qt.Key_Back)
			{
				if(control.selectionBar.count> 0)
					control.clearSelection()
					else
						control.goBack()
			}
			
			// Shortcut for clearing selection and filtering
			if(event.key == Qt.Key_Escape)
			{
				if(control.selectionBar.count > 0)
					control.clearSelection()
					
					control.browserView.filter = ""
			}
			
			//Shortcut for opening filtering
			if((event.key == Qt.Key_F) && (event.modifiers & Qt.ControlModifier))
            {
                control.toggleStatusBar()				
            }
            
            if(event.key == Qt.Key_Space)
            {
                control.previewer.show(currentFMModel, index)
                
            }
            
            control.keyPress(event)
            //             event.accepted = true
        }
        
		onItemsSelected:
		{
			control.selectIndexes(indexes)
		}
		
		onItemClicked:
		{
			browserView.currentView.currentIndex = index
			indexHistory.push(index)
			control.itemClicked(index)
			browserView.currentView.forceActiveFocus()
		}
		
		onItemDoubleClicked:
		{
			browserView.currentView.currentIndex = index
			indexHistory.push(index)
			control.itemDoubleClicked(index)
			browserView.currentView.forceActiveFocus()
		}
		
		onItemRightClicked:
		{
			if(control.currentFMList.pathType !== Maui.FMList.TRASH_PATH && control.currentFMList.pathType !== Maui.FMList.REMOTE_PATH)
			{
				itemMenu.show(index)
			}
			control.itemRightClicked(index)
			browserView.currentView.forceActiveFocus()
		}
		
		onLeftEmblemClicked:
		{
			const item = control.currentFMList.get(index)
			
			if(control.selectionBar.contains(item.path))
			{
				control.selectionBar.removeAtUri(item.path)
			}else
			{
				control.addToSelection(item)
			}
			control.itemLeftEmblemClicked(index)
			browserView.currentView.forceActiveFocus()
		}
		
		onRightEmblemClicked:
		{
			Maui.Handy.isAndroid ? Maui.Android.shareDialog([control.currentFMList.get(index).path]) : shareDialog.show([control.currentFMList.get(index).path])
			control.itemRightEmblemClicked(index)
		}
		
		onAreaClicked:
		{
			if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
				browserMenu.show(control)
				else return
					
					control.rightClicked()
					browserView.currentView.forceActiveFocus()
		}
		
		onAreaRightClicked: browserMenu.show(control)

        //        onWarning:
        //        {
        //            notify("dialog-information", "An error happened", message)
        //        }

        //        onProgress:
        //        {
        //            if(percent === 100)
        //                _progressBar.value = 0
        //            else
        //                _progressBar.value = percent/100
        //        }
    }

    
    ObjectModel { id: tabsObjectModel }

    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        spacing: 0

        Maui.TabBar
        {
            id: tabsBar
            visible: _browserList.count > 1
            Layout.fillWidth: true
            Layout.preferredHeight: tabsBar.implicitHeight
            position: TabBar.Header
            currentIndex : _browserList.currentIndex

            ListModel { id: tabsListModel }

            Keys.onPressed:
            {
                if(event.key == Qt.Key_Return)
                {
                    _browserList.currentIndex = currentIndex                    
                }
                
                if(event.key == Qt.Key_Down)
                {
                     browserView.currentView.forceActiveFocus()
                }
            }

            Repeater
            {
                id: _repeater
                model: tabsListModel

                Maui.TabButton
                {
                    id: _tabButton
                    implicitHeight: tabsBar.implicitHeight
                    implicitWidth: Math.max(control.width / _repeater.count, 120)
                    checked: index === _browserList.currentIndex

                    text: tabsObjectModel.get(index).currentFMList.pathName

                    onClicked:
                    {
                        _browserList.currentIndex = index
                    }

                    onCloseClicked: control.closeTab(index)
                }
            }
        }
        
        Flickable
        {
			Layout.margins: 0
			Layout.fillWidth: true
			Layout.fillHeight: true
			
			ListView
			{
				id: _browserList
				anchors.fill: parent
				clip: true
				focus: true
				orientation: ListView.Horizontal
				model: tabsObjectModel
				snapMode: ListView.SnapOneItem
				spacing: 0
				interactive: Kirigami.Settings.hasTransientTouchInput && tabsObjectModel.count > 1
				highlightFollowsCurrentItem: true
				highlightMoveDuration: 0
				highlightResizeDuration: 0
				highlightRangeMode: ListView.StrictlyEnforceRange
				preferredHighlightBegin: 0
				preferredHighlightEnd: width
				highlight: Item {}				
				highlightMoveVelocity: -1
				highlightResizeVelocity: -1
				
				onMovementEnded: _browserList.currentIndex = indexAt(contentX, contentY)
				boundsBehavior: Flickable.StopAtBounds 
				
				onCurrentItemChanged:
				{  
					control.currentPath =  tabsObjectModel.get(currentIndex).path
					_viewTypeGroup.currentIndex = browserView.viewType
					browserView.currentView.forceActiveFocus()
				}
				
				// 			DropArea
				// 			{
				// 				id: _dropArea
				// 				anchors.fill: parent
				// 				z: parent.z -2
				// 				onDropped:
				// 				{
				// 					const urls = drop.urls
				// 					for(var i in urls)
				// 					{
				// 						const item = Maui.FM.getFileInfo(urls[i])
				// 						if(item.isdir == "true")
				// 						{
				// 							control.openTab(urls[i])
				// 						}
				// 					}
				// 				}
				// 			}
			}
		}
        
        MauiLab.SelectionBar
        {
			id: _selectionBar
			
			Layout.alignment: Qt.AlignHCenter
			Layout.margins: Maui.Style.space.medium
			Layout.preferredWidth: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
			Layout.bottomMargin: Maui.Style.contentMargins*2
			maxListHeight: _browserList.height - (Maui.Style.contentMargins*2)
			singleSelection: settings.singleSelection
			
			onCountChanged:
			{
				if(_selectionBar.count < 1)
					control.clearSelection()
			}
			
			onUrisDropped: 
			{
                for(var i in uris)
                {
                    console.log(uris[i])
                    if(!Maui.FM.fileExists(uris[i]))
                        continue;
                    
                    const item = Maui.FM.getFileInfo(uris[i])
                    control.selectionBar.append(item.path, item)
                    
                }
            }

            onExitClicked: control.clearSelection()

            listDelegate: Maui.ListBrowserDelegate
            {
                Kirigami.Theme.inherit: true
                width: parent.width
                height: Maui.Style.iconSizes.big + Maui.Style.space.big
                label1.text: model.label
                label2.text: model.path
                label3.text: ""
				label4.text: ""
                showEmblem: true
                keepEmblemOverlay: true
                showThumbnails: true
                leftEmblem: "list-remove"
                folderSize: Maui.Style.iconSizes.big
                onLeftEmblemClicked: _selectionBar.removeAtIndex(index)
                background: Item {}
                onClicked: 
                {
                    _selectionBar.selectionList.currentIndex = index
                    control.previewer.show(_selectionBar.selectionList.model, _selectionBar.selectionList.currentIndex )
                }

                onPressAndHold: removeAtIndex(index)
            }
        }
        

        ProgressBar
        {
            id: _progressBar
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            Layout.preferredHeight: visible ? Maui.Style.iconSizes.medium : 0
            visible: value > 0
        }
    }

    Component.onCompleted:
    {
        openTab(control.currentPath && String(control.currentPath).length > 0 ? control.currentPath : Maui.FM.homePath())
        browserView.currentView.forceActiveFocus()
    }

//     onThumbnailsSizeChanged:
//     {
//         if(settings.trackChanges && settings.saveDirProps)
//             Maui.FM.setDirConf(currentPath+"/.directory", "MAUIFM", "IconSize", thumbnailsSize)
//             else
//                 Maui.FM.saveSettings("IconSize", thumbnailsSize, "SETTINGS")
// 
//                 if(browserView.viewType === Maui.FMList.ICON_VIEW)
//                     browserView.currentView.adaptGrid()
//     }

    function closeTab(index)
    {
        tabsObjectModel.remove(index)
        tabsListModel.remove(index)
    }

    function openTab(path)
    {
        if(path)
        {
            const component = Qt.createComponent("private/BrowserView.qml");
            if (component.status === Component.Ready)
            {
                const object = component.createObject(tabsObjectModel, {'path': path, 'viewType': _viewTypeGroup.currentIndex});
                tabsObjectModel.append(object)

                tabsListModel.append({"path": path})
                _browserList.currentIndex = tabsObjectModel.count - 1

            }
        }
    }
    
    function tagFiles(urls)
    {
        dialogLoader.sourceComponent = tagsDialogComponent
                dialog.composerList.urls = urls
                dialog.open()
    }

    function shareFiles(urls)
    {
        if(urls.length <= 0)
            return;

        dialogLoader.sourceComponent= shareDialogComponent
        dialog.urls = urls
        dialog.open()
    }

    function openItem(index)
    {
        const item = control.currentFMList.get(index)
        const path = item.path

        switch(control.currentFMList.pathType)
        {
            case Maui.FMList.CLOUD_PATH:
                if(item.isdir === "true")
                {
                    control.openFolder(path)
                }
                else
                {
                    Maui.FM.openCloudItem(item)
                }
                break;
            default:
                if(settings.selectionMode && item.isdir == "false")
                {
                    if(control.selectionBar.contains(item.path))
                    {
                        control.selectionBar.removeAtPath(item.path)
                    }else
                    {
                        control.addToSelection(item)
                    }
                }
                else
                {
                    if(item.isdir == "true")
                    {
                        control.openFolder(path)
                    }
                    else
                    {
                        if (Kirigami.Settings.isMobile)
                        {
                            control.previewer.show(currentFMModel, index)
                        }
                        else
                        {
                            control.openFile(path)
                        }
                    }
                }
        }
    }

    function openFile(path)
    {
        Maui.FM.openUrl(path)
    }

    function openFolder(path)
    {
        if(!String(path).length)
            return;

        control.currentPath = path
    }

    function goBack()
    {
        openFolder(control.currentFMList.previousPath)
        //        browserView.currentView.currentIndex = indexHistory.pop()
    }

    function goNext()
    {
        openFolder(control.currentFMList.posteriorPath)
    }

    function goUp()
    {
        openFolder(control.currentFMList.parentPath)
    }

    function refresh()
    {
        const pos = browserView.currentView.contentY
        browserView.currentView.contentY = pos
    }

    function addToSelection(item)
    {
        if(item.path.startsWith("tags://") || item.path.startsWith("applications://") )
        {
            return
        }
        
        control.selectionBar.append(item.path, item)
    }

    function clearSelection()
    {
        control.selectionBar.clear()
        settings.selectionMode = false
    }

    function copy(urls)
    {
        Maui.Handy.copyToClipboard({"urls": urls})
        control.isCut = false
        control.isCopy = true
    }

    function cut(urls)
    {
        Maui.Handy.copyToClipboard({"urls": urls})
        control.isCut = true
        control.isCopy = false
    }

    function paste()
    {
        const urls = Maui.Handy.getClipboard().urls

        if(!urls)
            return

            if(control.isCut)
            {
                control.currentFMList.cutInto(urls)
                control.clearSelection()
            }else
            {
                control.currentFMList.copyInto(urls)
            }
    }

    function remove(urls)
    {
        dialogLoader.sourceComponent= removeDialogComponent
        dialog.urls = urls
        dialog.open()
    }
    
    function selectIndexes(indexes)
    {
        for(var i in indexes)
             addToSelection(control.currentFMList.get(indexes[i]))
    }

    function selectAll() //TODO for now dont select more than 100 items so things dont freeze or break
    {
        selectIndexes([...Array( Math.min(control.currentFMList.count, 100)).keys()])       
    }

    function bookmarkFolder(paths) //multiple paths
    {
        for(var i in paths)
        {
			Maui.FM.bookmark(paths[i])
		}
    }

    function zoomIn()
    {
        control.browserView.currentView.resizeContent(1.2)
    }
    
    function zoomOut()
    {
        control.browserView.currentView.resizeContent(0.8)
        
    }

    function groupBy()
    {
        var prop = ""
        var criteria = ViewSection.FullString

        switch(control.currentFMList.sortBy)
        {
            case Maui.FMList.LABEL:
                prop = "label"
                criteria = ViewSection.FirstCharacter
                break;
            case Maui.FMList.MIME:
                prop = "mime"
                break;
            case Maui.FMList.SIZE:
                prop = "size"
                break;
            case Maui.FMList.DATE:
                prop = "date"
                break;
            case Maui.FMList.MODIFIED:
                prop = "modified"
                break;
        }

        if(!prop)
        {
            control.browserView.currentView.section.property = ""
            return
        }

        control.browserView.viewType = Maui.FMList.LIST_VIEW
        control.browserView.currentView.section.property = prop
        control.browserView.currentView.section.criteria = criteria
    }
    
    function toggleStatusBar()
    {
        control.footBar.visible = !control.footBar.visible
        Maui.FM.saveSettings("StatusBar",  control.footBar.visible, "SETTINGS")	
        
        if(control.footBar.visible)
        {
            _filterField.forceActiveFocus()
        }else
        {
            browserView.currentView.forceActiveFocus()
        }
    }
}

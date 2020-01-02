/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.impl 2.3
import QtQuick.Templates 2.3 as T
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

T.ToolButton
{
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: Maui.Style.space.tiny
    spacing: Maui.Style.space.tiny
    rightPadding: Maui.Style.space.medium
    leftPadding: Maui.Style.space.medium
    topPadding: Maui.Style.space.small
    bottomPadding: Maui.Style.space.small
    icon.width: Maui.Style.iconSizes.medium
    icon.height: Maui.Style.iconSizes.medium
    icon.color: checked  ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
    
    flat: control.parent === T.ToolBar

    font.pointSize: control.display === ToolButton.TextUnderIcon ? Maui.Style.fontSizes.small : undefined
    contentItem: IconLabel
    {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: control.checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor

        Behavior on color
        {
            ColorAnimation
            {
                duration: Kirigami.Units.longDuration
            }
        }
    }

    background: Rectangle
    {
        implicitWidth: Maui.Style.iconSizes.medium
        implicitHeight: Maui.Style.iconSizes.medium
        
        radius: height * 0.07

        opacity: control.checked ? 0.4 : 1.0
        color: (control.down || control.checked || control.highlighted ? Kirigami.Theme.highlightColor : "transparent")

        Behavior on color
        {
            ColorAnimation
            {
                duration: Kirigami.Units.longDuration
            }
        }
    }
}

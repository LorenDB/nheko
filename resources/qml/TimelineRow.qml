import "./delegates"
import "./emoji"
import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import im.nheko 1.0

Item {
    anchors.left: parent.left
    anchors.right: parent.right
    height: row.height

    Rectangle {
        color: (Settings.messageHoverHighlight && hoverHandler.hovered) ? colors.alternateBase : "transparent"
        anchors.fill: row
    }

    HoverHandler {
        id: hoverHandler

        acceptedDevices: PointerDevice.GenericPointer
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onSingleTapped: messageContextMenu.show(model.id, model.type, model.isEncrypted, model.isEditable, row, mapToItem(timelineRoot, eventPoint.position.x, eventPoint.position.y))
    }

    TapHandler {
        onLongPressed: messageContextMenu.show(model.id, model.type, model.isEncrypted, model.isEditable, row, mapToItem(timelineRoot, point.position.x, point.position.y))
        onDoubleTapped: chat.model.reply = model.id
    }

    RowLayout {
        id: row

        anchors.leftMargin: avatarSize + 16
        anchors.left: parent.left
        anchors.right: parent.right

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 4

            // fancy reply, if this is a reply
            Reply {
                visible: model.replyTo
                modelData: chat.model.getDump(model.replyTo, model.id)
                userColor: TimelineManager.userColor(modelData.userId, colors.base)
            }

            // actual message content
            MessageDelegate {
                id: contentItem

                width: parent.width
                modelData: model
            }

            Reactions {
                id: reactionRow

                reactions: model.reactions
                eventId: model.id
            }

        }

        StatusIndicator {
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.preferredHeight: 16
            width: 16
        }

        EncryptionIndicator {
            visible: model.isRoomEncrypted
            encrypted: model.isEncrypted
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.preferredHeight: 16
            width: 16
        }

        ImageButton {
            id: editButton

            visible: (Settings.buttonsInTimeline && model.isEditable && hoverHandler.hovered) || model.isEdited
            buttonTextColor: chat.model.edit == model.id ? colors.highlight : colors.buttonText
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.preferredHeight: 16
            width: 16
            hoverEnabled: true
            image: ":/icons/icons/ui/edit.png"
            ToolTip.visible: hovered
            ToolTip.text: model.isEditable ? qsTr("Edit") : qsTr("Edited")
            onClicked: {
                if (model.isEditable)
                    chat.model.editAction(model.id);

            }
        }

        EmojiButton {
            id: reactButton

            visible: Settings.buttonsInTimeline && hoverHandler.hovered
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.preferredHeight: 16
            width: 16
            hoverEnabled: true
            ToolTip.visible: hovered
            ToolTip.text: qsTr("React")
            emojiPicker: emojiPopup
            event_id: model.id
        }

        ImageButton {
            id: replyButton

            visible: Settings.buttonsInTimeline && hoverHandler.hovered
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.preferredHeight: 16
            width: 16
            hoverEnabled: true
            image: ":/icons/icons/ui/mail-reply.png"
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Reply")
            onClicked: chat.model.replyAction(model.id)
        }

        ImageButton {
            id: optionsButton

            visible: Settings.buttonsInTimeline && hoverHandler.hovered
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.preferredHeight: 16
            width: 16
            hoverEnabled: true
            image: ":/icons/icons/ui/vertical-ellipsis.png"
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Options")
            onClicked: messageContextMenu.show(model.id, model.type, model.isEncrypted, model.isEditable, optionsButton)
        }

        Label {
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            text: model.timestamp.toLocaleTimeString("HH:mm")
            width: Math.max(implicitWidth, text.length * fontMetrics.maximumCharacterWidth)
            color: inactiveColors.text
            ToolTip.visible: ma.hovered
            ToolTip.text: Qt.formatDateTime(model.timestamp, Qt.DefaultLocaleLongDate)

            HoverHandler {
                id: ma
            }

        }

    }

}

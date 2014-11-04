import QtQuick 2.0
import QtQuick.Layouts 1.1

//test 20% et 80%
Rectangle {
    width: 500
    height: 500

    RowLayout {
        id: layout
        anchors.fill: parent
           spacing: 0
        Rectangle {
            color: 'teal'
            Layout.fillWidth: true
            Layout.minimumWidth: parent.width*(20/100)
            Layout.maximumWidth:  parent.width*(20/100)
            Layout.minimumHeight: parent.height
            Text {
                anchors.centerIn: parent
                text: parent.width + 'x' + parent.height
            }
        }
        Rectangle {
            color: 'plum'
            Layout.minimumWidth: parent.width*(80/100)
            Layout.maximumWidth:  parent.width*(80/100)
            Layout.minimumHeight: parent.height
            Text {
                anchors.centerIn: parent
                text: parent.width + 'x' + parent.height
            }
        }
    }
}

QT *= macextras

QMAKE_APPLE_SIMULATOR_ARCHS = x86_64
LIBS += -framework Foundation -framework Cocoa

INCLUDEPATH += /System/Library/Frameworks/Foundation.framework/Versions/C/Headers \
               /System/Library/Frameworks/AppKit.framework/Headers \
               /System/Library/Frameworks/Cocoa.framework/Headers

SOURCES += $$PWD/mauimacos.mm \
#    $$PWD/qfsharepicker.mm \
#    $$PWD/share.mm

HEADERS += $$PWD/mauimacos.h \


#OBJECTIVE_HEADERS += $$PWD/qfsharepicker.h \
#    $$PWD/share.h


DEPENDPATH += \
    $$PWD

INCLUDEPATH += \
     $$PWD

LIBS += -L$$PWD/../../../../../../../../usr/local/Cellar/kde-ki18n/5.72.0/lib/ -lKF5I18n.5.72.0

INCLUDEPATH += $$PWD/../../../../../../../../usr/local/Cellar/kde-ki18n/5.72.0/include
DEPENDPATH += $$PWD/../../../../../../../../usr/local/Cellar/kde-ki18n/5.72.0/include

#ifndef TAGSLIST_H
#define TAGSLIST_H

#include "fmh.h"
#include "tag.h"
#include <QObject>

#include "mauilist.h"

class Tagging;

/**
 * @brief The TagsList class
 * A model ready to be consumed by QML. Has basic support for browsing and handling tags, appending and removing
 */
class TagsList : public MauiList
{
    Q_OBJECT

    Q_PROPERTY(bool abstract READ getAbstract WRITE setAbstract NOTIFY abstractChanged)
    Q_PROPERTY(bool strict READ getStrict WRITE setStrict NOTIFY strictChanged)
    Q_PROPERTY(QStringList urls READ getUrls WRITE setUrls NOTIFY urlsChanged)
    Q_PROPERTY(QStringList tags READ getTags NOTIFY tagsChanged)
    Q_PROPERTY(QString lot READ getLot WRITE setLot NOTIFY lotChanged)
    Q_PROPERTY(QString key READ getKey WRITE setKey NOTIFY keyChanged)

    Q_PROPERTY(TagsList::KEYS sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged())

public:

    //!
    //! \brief The KEYS enum
    //!
    enum KEYS : uint_fast8_t {
        URL = FMH::MODEL_KEY::URL,
        APP = FMH::MODEL_KEY::APP,
        URI = FMH::MODEL_KEY::URI,
        MAC = FMH::MODEL_KEY::MAC,
        LAST_SYNC = FMH::MODEL_KEY::LASTSYNC,
        NAME = FMH::MODEL_KEY::NAME,
        VERSION = FMH::MODEL_KEY::VERSION,
        LOT = FMH::MODEL_KEY::LOT,
        TAG = FMH::MODEL_KEY::TAG,
        COLOR = FMH::MODEL_KEY::COLOR,
        ADD_DATE = FMH::MODEL_KEY::ADDDATE,
        COMMENT = FMH::MODEL_KEY::COMMENT,
        MIME = FMH::MODEL_KEY::MIME,
        TITLE = FMH::MODEL_KEY::TITLE,
        DEVICE = FMH::MODEL_KEY::DEVICE,
        KEY = FMH::MODEL_KEY::KEY
    };
    Q_ENUM(KEYS)

    explicit TagsList(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override;

    TagsList::KEYS getSortBy() const;
    void setSortBy(const TagsList::KEYS &key);

    bool getAbstract() const;
    void setAbstract(const bool &value);

    bool getStrict() const;
    void setStrict(const bool &value);

    QStringList getUrls() const;
    void setUrls(const QStringList &value);

    QString getLot() const;
    void setLot(const QString &value);

    QString getKey() const;
    void setKey(const QString &value);

    QStringList getTags() const;

private:
    FMH::MODEL_LIST list;
    void setList();
    void sortList();
    Tagging *tag;

    bool abstract = false;
    bool strict = true;
    QStringList urls = QStringList();
    QString lot;
    QString key;
    TagsList::KEYS sortBy = TagsList::KEYS::ADD_DATE;

signals:
    void abstractChanged();
    void strictChanged();
    void urlsChanged();
    void lotChanged();
    void keyChanged();
    void sortByChanged();
    void tagsChanged();

public slots:

    /**
     * @brief get
     * Return the data of a item in the model at the given index
     * @param index
     * @return
     */
    QVariantMap get(const int &index) const;

    /**
     * @brief append
     * Adds a given tag to the model, if the tag already exist in the model then nothing happens.
     * This operation does not inserts the tag to the tagging data base.
     * @param tag
     * The tag to be aaded to the model
     */
    void append(const QString &tag);

    /**
     * @brief append
     * Adds a given list of tags to the model. Tags that already exists in the model are ignored
     * @param tags
     * List of tags to be added to the model
     */
    void append(const QStringList &tags);

    /**
     * @brief insert
     * Inserts a tag to the tagging data base.
     * @param tag
     * Tag to be inserted
     * @return
     * If the tag already exists in the data base then it return false, if the operation is sucessfull returns true
     */
    bool insert(const QString &tag);

    /**
     * @brief insertToUrls
     * Associates a given tag to the current file URLs set to the urls property
     * @param tag
     * A tag to be associated, if the tag doesnt exists then it gets created
     */
    void insertToUrls(const QString &tag);

    /**
     * @brief insertToAbstract /\deprecated
     * @param tag
     */
    void insertToAbstract(const QString &tag);

    /**
     * @brief updateToUrls
     * Updates a list of tags associated to the current file URLs. All the previous tags associated to each file URL are removed and replaced by the new ones
     * @param tags
     * Tags to be updated
     */
    void updateToUrls(const QStringList &tags);

    /**
     * @brief updateToAbstract \deprecated
     * @param tags
     */
    void updateToAbstract(const QStringList &tags);

    /**
     * @brief remove
     * Removes a tag from the model at a given index. The tag is removed from the model but not from the tagging data base
     * @param index
     * Index of the tag in the model. If the model has been filtered or ordered using the Maui BaseModel then it should use the mapped index.
     * @return
     */
    bool remove(const int &index);

    /**
     * @brief removeFrom
     * Removes a tag at the given index in the model from the given file URL. This removes the associated file URL from the tagging data base and  the tag from the model
     * @param index
     * Index of the tag in the model
     * @param url
     * File URL
     */
    void removeFrom(const int &index, const QString &url);

    /**
     * @brief removeFrom \deprecated
     * @param index
     * @param key
     * @param lot
     */
    void removeFrom(const int &index, const QString &key, const QString &lot);

    /**
     * @brief removeFromUrls
     * Removes a tag at a given index in the model from the all the file URls currently set
     * @param index
     * Index of the tag in the model.
     */
    void removeFromUrls(const int &index);

    /**
     * @brief removeFromUrls
     * Removes a given tag name from the current list of file URLs set
     * @param tag
     */
    void removeFromUrls(const QString &tag);

    /**
     * @brief removeFromAbstract \deprecated
     * @param index
     */
    void removeFromAbstract(const int &index);

    /**
     * @brief erase
     * Removes a tag from the tagging data base. This operation will remove the association of the tag to the current application making the request, meaning that if the tag is also associated to another application then the tag will still exists
     * @param index
     */
    void erase(const int &index);

    /**
     * @brief refresh
     * Reloads the model, checking the tags from the given list of file URLs
     */
    void refresh();

    /**
     * @brief contains
     * Checks if a given tag name is already in the model list
     * @param tag
     * Tag name to look up
     * @return
     * True if the tag exists false otherwise
     */
    bool contains(const QString &tag);

    /**
     * @brief indexOf
     * Returns the index of a given tag name in the model list, if the tag is not present then -1 is returned.
     * @param tag
     * Tag name to be look up
     * @return
     * The index of the tag in the model or -1. This operation does not map the index to a fitered or sorted model, to get a matched index in such case use the mapping methods from the Maui Base Model
     */
    int indexOf(const QString &tag);
};

#endif // TAGSLIST_H

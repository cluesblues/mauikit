/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2019  camilo <chiguitar@unal.edu.co>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef MAUILIST_H
#define MAUILIST_H
#include "fmh.h"

/**
 * @todo write docs
 */
#include <QObject>

class MauiList : public QObject
{
    Q_OBJECT

public:
    /**
     * Default constructor
     */
	explicit MauiList(QObject *parent = nullptr);
	~MauiList();
	
	virtual FMH::MODEL_LIST items() const {return FMH::MODEL_LIST();};
	
signals:
	void preItemAppended();
	void postItemAppended();
    void preItemAppendedAt(int index);
	void preItemRemoved(int index);
	void postItemRemoved();
	void updateModel(int index, QVector<int> roles);
	void preListChanged();
	void postListChanged();

};

#endif // MAUILIST_H
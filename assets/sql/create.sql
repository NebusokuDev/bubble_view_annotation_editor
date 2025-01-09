CREATE TABLE annotations
(
    id         INTEGER PRIMARY KEY,
    image_path TEXT
);

CREATE TABLE key_points
(
    id            INTEGER PRIMARY KEY,
    annotation_id INTEGER,
    x             REAL,
    y             REAL,
    FOREIGN KEY (annotation_id) REFERENCES annotations (id) ON DELETE CASCADE
);

CREATE TABLE click_points
(
    id            INTEGER PRIMARY KEY,
    annotation_id INTEGER,
    x             REAL,
    y             REAL,
    FOREIGN KEY (annotation_id) REFERENCES annotations (id) ON DELETE CASCADE
);

CREATE TABLE labels
(
    id   INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE annotation_labels
(
    annotation_id INTEGER,
    label_id      INTEGER,
    PRIMARY KEY (annotation_id, label_id),
    FOREIGN KEY (annotation_id) REFERENCES annotations (id) ON DELETE CASCADE,
    FOREIGN KEY (label_id) REFERENCES labels (id) ON DELETE CASCADE
);

CREATE TABLE bounds
(
    id            INTEGER PRIMARY KEY,
    annotation_id INTEGER,
    path          TEXT,
    label_id      INTEGER,
    FOREIGN KEY (annotation_id) REFERENCES annotations (id) ON DELETE CASCADE,
    FOREIGN KEY (label_id) REFERENCES labels (id) ON DELETE SET NULL
);

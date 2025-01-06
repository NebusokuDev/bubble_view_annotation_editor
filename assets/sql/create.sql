CREATE TABLE annotations
(
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    image                 BLOB NOT NULL,
    keyPoints             TEXT,
    bubbleViewClickPoints TEXT,
    label                 TEXT,
    bounds                TEXT
);

-- Split the `annotations` table into multiple tables to normalize the schema

-- Table to store general annotation data
CREATE TABLE annotations_base
(
    id    INTEGER PRIMARY KEY AUTOINCREMENT,
    image BLOB NOT NULL
);

-- Table to store key points
CREATE TABLE key_points
(
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    annotation_id INTEGER NOT NULL,
    keyPoints     TEXT,
    FOREIGN KEY (annotation_id) REFERENCES annotations_base (id)
);

-- Table to store bubble view click points
CREATE TABLE bubble_click_points
(
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    annotation_id         INTEGER NOT NULL,
    bubbleViewClickPoints TEXT,
    FOREIGN KEY (annotation_id) REFERENCES annotations_base (id)
);

-- Table to store labels
CREATE TABLE labels
(
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    annotation_id INTEGER NOT NULL,
    label         TEXT,
    FOREIGN KEY (annotation_id) REFERENCES annotations_base (id)
);

-- Table to store bounds
CREATE TABLE bounds
(
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    annotation_id INTEGER NOT NULL,
    bounds        TEXT,
    FOREIGN KEY (annotation_id) REFERENCES annotations_base (id)
);

-- Migrate the data from the original `annotations` table to the new schema
INSERT INTO annotations_base (id, image)
SELECT id, image
FROM annotations;

INSERT INTO key_points (annotation_id, keyPoints)
SELECT id, keyPoints
FROM annotations
WHERE keyPoints IS NOT NULL;

INSERT INTO bubble_click_points (annotation_id, bubbleViewClickPoints)
SELECT id, bubbleViewClickPoints
FROM annotations
WHERE bubbleViewClickPoints IS NOT NULL;

INSERT INTO labels (annotation_id, label)
SELECT id, label
FROM annotations
WHERE label IS NOT NULL;

INSERT INTO bounds (annotation_id, bounds)
SELECT id, bounds
FROM annotations
WHERE bounds IS NOT NULL;

-- Optional: Drop the original `annotations` table if no longer needed
-- DROP TABLE annotations;

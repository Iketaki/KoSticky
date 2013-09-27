KoSticky
========
Kossy製のメモアプリ

Setup & Usage
========
* carton install
* mysqlに **kostickies** というDBを作成
* mysql -u {DB_USER} -p {DB_PASS} < sql/schema.sql
* ./Configを編集
* plackup -r app.psgi

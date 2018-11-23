#! /bin/bash

npm run build && \
rm -f /Volumes/www/php/tw/dist/index.html && \
rm -frv /Volumes/www/php/tw/dist/static && \
cp  dist/index.html /Volumes/www/php/tw/dist/ && \
cp -R  dist/static /Volumes/www/php/tw/dist/ && \
echo "OK released."

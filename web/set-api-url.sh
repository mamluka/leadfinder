#!/bin/bash

cp app/js/api-url.js.template app/js/api-url.js

sed --in-place 's/apiUrlTemplate/$1/g' app/js/api-url.js
sed --in-place 's/domainTemplate/$2/g' app/js/api-url.js



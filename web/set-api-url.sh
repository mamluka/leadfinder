#!/bin/bash

cp app/js/api-url.js.template app/js/api-url.js

sed --in-place 's/apiUrlTenplate/$1/g' app/js/api-url.js



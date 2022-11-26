mkdir -p src/declarations/test
$(dfx cache show)/moc src/test/Main.mo -c --debug --idl --stable-types --public-metadata candid:service --actor-idl src/declarations/test/idl/ --package base $(dfx cache show)/base -o src/declarations/test/test.wasm
# didc bind src/declarations/test/test.did -t js > src/declarations/test/test.did.js
# didc bind src/declarations/test/test.did -t ts > src/declarations/test/test.t.ts
ic-wasm src/declarations/test/test.wasm -o src/declarations/test/test.wasm shrink
gzip -c src/declarations/test/test.wasm > src/declarations/test/test.wasm.gz
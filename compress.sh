mkdir -p src/declarations/test
$(dfx cache show)/moc --idl src/test/Main.mo  --package base $(dfx cache show)/base -o src/declarations/test/test.did
didc bind src/declarations/test/test.did -t js > src/declarations/test/test.did.js
didc bind src/declarations/test/test.did -t ts > src/declarations/test/test.t.ts
$(dfx cache show)/moc src/test/Main.mo  -o src/declarations/test/test.did  --package base $(dfx cache show)/base -o src/declarations/test/test.wasm

gzip -c src/declarations/test/test.wasm > src/declarations/test/test.wasm.gz
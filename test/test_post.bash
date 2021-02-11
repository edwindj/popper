set -e

pushd ..
docker-compose up --build -d
popd

curl -d @data.json \
     -H "Content-Type:application/json"    \
     -X POST http://localhost:3001/pdf     \
     -o out.pdf

# pushd ..
# docker-compose down
# popd

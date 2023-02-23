echo "📦 Installing jsonnet packages"
jb install

echo "🚢 Build docker images"
docker-compose build

echo "📦 Installing Gems"
docker-compose run --rm app bundle

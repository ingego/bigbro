FROM dart:stable AS build
WORKDIR /app

COPY pubspec.* ./

# Устанавливаем зависимости проекта
RUN dart pub get

# Копируем все остальные файлы проекта
COPY . .

#RUN dart run
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline

# CMD [ "dart", "run" ]
RUN dart compile exe bin/bigbro.dart -o bin/server
#RUN dart compile exe bin/server.dart -o bin/server

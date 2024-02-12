.SILENT:

# Inicia los contenedores de desarrollo en modo watch
build-dev:
	docker-compose --env-file .docker.env -f ./docker-compose-local.yml up --build
	
# Inicia los contenedores de desarrollo en segundo plano
start-dev:
	docker-compose --env-file .docker.env -f ./docker-compose-local.yml up

# Borrar contenedores de desarrollo
rm-dev:
	@ERRORS=""; \
	for CONTAINER in meli_postgresql_service meli_pgadmin_service ecommerce_dev; do \
		if docker ps -a | grep -q $$CONTAINER; then \
			docker rm -fv $$CONTAINER 2>/dev/null || ERRORS="$$ERRORS Error al eliminar el contenedor $$CONTAINER.\n"; \
		else \
			ERRORS="$$ERRORS$$CONTAINER.\n"; \
		fi; \
	done; \
	echo -e "$$ERRORS"; \
	echo "Se han borrado los contenedores con éxito"
# Ingresar al contenedor de desarrollo ecommerce_dev
in-dev:
	docker exec -it ecommerce_dev /bin/sh

# Detiene y elimina todos los contenedores que están en ejecución del ambiente desarrollo
stop-dev:
	docker-compose -f ./docker-compose-local.yml down

# Inicia los contenedores de producción
start-prod:
	docker-compose -f ./docker-compose-prod.yml up -d --build

# Ancla el proceso del contenedor al shell
start-prod-watch:
	docker-compose --env-file .docker.env -f ./docker-compose-prod.yml up --build

# Construir imagen producción
build-prod:
	docker-compose -f ./docker-compose-prod.yml up -d --build

# Ingresar al contenedor de producción ecommerce_prod
in-prod:
	docker exec -it ecommerce_prod /bin/sh

# Detiene y elimina todos los contenedores que están en ejecución del ambiente de produccion
stop-prod:
	docker-compose -f ./docker-compose-prod.yml down

# Detiene todos los contenedores que están en ejecución del ambiente desarrollo - producción
stop-all:
	stop-prod
	stop-dev
	echo "Deteniendo todos los contenedores de produccion y desarrollo"

# Borrar contenedores de produccion
rm-prod:
	@ERRORS=""; \
	for CONTAINER in meli_postgresql_service meli_pgadmin_service ecommerce_prod; do \
		if docker ps -a | grep -q $$CONTAINER; then \
			docker rm -fv $$CONTAINER 2>/dev/null || ERRORS="$$ERRORS Error al eliminar el contenedor $$CONTAINER.\n"; \
		else \
			ERRORS="$$ERRORS$$CONTAINER.\n"; \
		fi; \
	done; \
	echo -e "$$ERRORS"; \
	echo "Se han borrado los contenedores con éxito"

# Borra todas las imagenes que tengan nombre <none> denominadas 'dangling images'
rm-dang:
	if [ "$$(docker images -f "dangling=true" -q)" ]; then \
		docker rmi $$(docker images -f "dangling=true" -q); \
		docker images; \
	else \
		echo "No hay imágenes para borrar."; \
	fi

define remove_container
	@if docker ps -a | grep -q $(1); then \
		docker rm -fv $(1) 2>/dev/null || ERRORS="$$ERRORS Error al eliminar el contenedor $(1)."; \
	else \
		ERRORS="$$ERRORS No existe el contenedor $(1)."; \
	fi
endef

# Construir la imagen de desarrollo con docker
docker-dev:
	docker build --no-cache -f Dockerfile.dev -t ecommerce_dev_img .
.PHONY: install test server

define install_bs
	which bs || (wget https://raw.githubusercontent.com/educabilia/bs/master/bin/bs && chmod +x bs && sudo mv bs /usr/local/bin)

	@if [ -s .gs ]; then \
		true; \
	else \
		mkdir .gs; \
		touch .env; \
		echo 'GEM_HOME=$$(pwd)/.gs' >> .env; \
		echo 'GEM_PATH=$$(pwd)/.gs' >> .env; \
		echo 'PATH=$$(pwd)/.gs/bin:$$PATH' >> .env; \
		echo 'RACK_ENV=development' >> .env; \
	fi;

	bs gem install dep
	bs gem install cutest-cj
	bs gem install pry
	bs gem install awesome_print
endef

install:
	$(call install_bs)
	bs dep install

test:
	bs env $$(cat .env.test) cutest test/**/*_test.rb

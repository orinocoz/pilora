#
# PiLoRa makefile
#

INSTALL_DIR?=/opt/pilora
LIBLORAGW_DIR=./lora_gateway
FORWARDER_DIR=./ttn_forwarder

.PHONY: build install

build:
	echo "Building libloragw"
	sed -i -e 's/PLATFORM= kerlink/PLATFORM= imst_rpi/g' $(LIBLORAGW_DIR)/libloragw/library.cfg
	make -C $(LIBLORAGW_DIR)

	echo "Building the packet forwarder"
	make -C $(FORWARDER_DIR)
	strip $(FORWARDER_DIR)/poly_pkt_fwd/poly_pkt_fwd

install: build
	echo "Installing into: $(INSTALL_DIR)"
	mkdir -p $(INSTALL_DIR)
	
	cp $(FORWARDER_DIR)/poly_pkt_fwd/poly_pkt_fwd $(INSTALL_DIR)/packet_forwarder
	cp ./iC880A_reset.sh $(INSTALL_DIR)/
	cp ./start.sh $(INSTALL_DIR)/

	chmod 0755 $(INSTALL_DIR)/packet_forwarder
	chmod 0755 $(INSTALL_DIR)/iC880A_reset.sh
	chmod 0755 $(INSTALL_DIR)/start.sh

	cp $(FORWARDER_DIR)/poly_pkt_fwd/global_conf.json $(INSTALL_DIR)/global_conf.json
	echo -e "{" > $(INSTALL_DIR)/local_conf.json
	echo -e "  \"gateway_conf\": {" >> $(INSTALL_DIR)/local_conf.json
	echo -e "    \"gateway_ID\": \"AA555A0000000000\"," >> $(INSTALL_DIR)/local_conf.json
	echo -e "    \"ref_latitude\": 0," >> $(INSTALL_DIR)/local_conf.json
	echo -e "    \"ref_longitude\": 0," >> $(INSTALL_DIR)/local_conf.json
	echo -e "    \"ref_altitude\": 0," >> $(INSTALL_DIR)/local_conf.json
	echo -e "    \"contact_email\": \"operator@gateway.ttn\"," >> $(INSTALL_DIR)/local_conf.json
	echo -e "    \"description\": \"The gateway\"," >> $(INSTALL_DIR)/local_conf.json
	echo -e "    \"servers\": {" >> $(INSTALL_DIR)/local_conf.json
	echo -e "      [ { \"server_address\": \"router.eu.thethings.network\", \"serv_port_up\": 1700, \"serv_port_down\": 1700, \"serv_enabled\": true } ]," >> $(INSTALL_DIR)/local_conf.json
	echo -e "    }," >> $(INSTALL_DIR)/local_conf.json
	echo -e "  }," >> $(INSTALL_DIR)/local_conf.json
	echo -e "}" >> $(INSTALL_DIR)/local_conf.json

	chmod 0644 $(INSTALL_DIR)/global_conf.json
	chmod 0644 $(INSTALL_DIR)/local_conf.json

	echo "Installation complete. Remember to edit $(INSTALL_DIR)/local_conf.json!"

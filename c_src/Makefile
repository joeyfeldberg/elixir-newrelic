INSTALL_PATH?=/usr/local/lib/
INC_PARAMS = $(PWD)/deps/cure/c_src
ELIXIR_COMM_C = $(INC_PARAMS)/elixir_comm.c
LIB_DIR = $(PWD)/c_src/lib/
C_FLAGS = -I$(INC_PARAMS) -O3 -fPIC
LDFLAGS = -L$(LIB_DIR) -lnewrelic-transaction  -lnewrelic-common  -lnewrelic-collector-client -lprotobuf
INSTALL_FILES = `find $(LIB_DIR) -type f 2>/dev/null`

ALL = clean newrelic

# Targets:
all: $(ALL)
clean:
	rm -f $(PWD)/c_src/newrelic
newrelic:
	gcc -o newrelic main.cc operation_msg.pb.cc $(ELIXIR_COMM_C) $(C_FLAGS) $(LDFLAGS)
install:
	install $(LIB_DIR)/*.so $(INSTALL_PATH)

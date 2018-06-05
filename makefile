include config.mak

LDFLAGS		=	-Bstatic							\
			-Wl,-Map=$(DIR_TARGETOUTPUT)/$(TARGET_NAME).map,--cref		\
			-T$(LDS_NAME).lds						\
			-Wl,--start-group						\
			-Lsrc/$(DIR_OBJOUTPUT)						\
			-Wl,--end-group							\
			-Wl,--build-id=none						\
			-nostdlib

SYS_OBJS	+=	startup.o libnx.o libplat.o libarmv7.o serial.o printf.o smc_entry.o 	\
			sip_main.o tz.o build_info.o main.o

SYS_OBJS_LIST	+=	$(addprefix $(DIR_OBJOUTPUT)/,$(SYS_OBJS))

SYS_INCLUDES	+=	-I src						\
			-I src/include					\
			-I src/include/configs				\
			-I src/lib					\
			-I src/drivers					\
			-I src/drivers/serial

###################################################################################################
$(DIR_OBJOUTPUT)/%.o: src/%.c
	@echo [compile....$<]
	$(Q)$(CC) -MMD $< -c -o $@ $(CFLAGS) $(SYS_INCLUDES)
###################################################################################################
$(DIR_OBJOUTPUT)/%.o: src/%.s
	@echo [compile....$<]
	$(Q)$(CC) -MMD $< -c -o $@ $(ASFLAG) $(CFLAGS) $(SYS_INCLUDES)
###################################################################################################
$(DIR_OBJOUTPUT)/%.o: src/lib/%.c
	@echo [compile....$<]
	$(Q)$(CC) -MMD $< -c -o $@ $(CFLAGS) $(SYS_INCLUDES)
###################################################################################################
$(DIR_OBJOUTPUT)/%.o: src/lib/%.s
	@echo [compile....$<]
	$(Q)$(CC) -MMD $< -c -o $@ $(ASFLAG) $(CFLAGS) $(SYS_INCLUDES)
###################################################################################################
$(DIR_OBJOUTPUT)/%.o: src/drivers/%.c
	@echo [compile....$<]
	$(Q)$(CC) -MMD $< -c -o $@ $(CFLAGS) $(SYS_INCLUDES)
###################################################################################################
$(DIR_OBJOUTPUT)/%.o: src/drivers/serial/%.c
	@echo [compile....$<]
	$(Q)$(CC) -MMD $< -c -o $@ $(CFLAGS) $(SYS_INCLUDES)
###################################################################################################
$(DIR_OBJOUTPUT)/%.o: src/services/%.s
	@echo [compile....$<]
	$(Q)$(CC) -MMD $< -c -o $@ $(ASFLAG) $(CFLAGS) $(SYS_INCLUDES)
###################################################################################################
$(DIR_OBJOUTPUT)/%.o: src/services/%.c
	@echo [compile....$<]
	$(Q)$(CC) -MMD $< -c -o $@ $(CFLAGS) $(SYS_INCLUDES)
###################################################################################################

all: mkobjdir $(SYS_OBJS_LIST) link bin gen

link:
	@echo [link.... $(DIR_TARGETOUTPUT)/$(TARGET_NAME).elf]
	$(Q)$(CC) $(SYS_OBJS_LIST) $(LDFLAGS) -o $(DIR_TARGETOUTPUT)/$(TARGET_NAME).elf

bin:
	@echo [binary.... $(DIR_TARGETOUTPUT)/$(TARGET_NAME).bin]
	$(Q)$(MAKEBIN) -O binary $(DIR_TARGETOUTPUT)/$(TARGET_NAME).elf $(DIR_TARGETOUTPUT)/$(TARGET_NAME).bin

gen:
	./tools/rsa_sign_new -n tools/nsih_256.txt -i out/${TARGET_NAME}.bin -b tools/bootkey -u tools/userkey -k bl2 -l 0x41000000 -s 0x41000000
	cp out/${TARGET_NAME}.bin.raw ~/


mkobjdir:
ifeq ($(OS),Windows_NT)
	@if not exist $(DIR_OBJOUTPUT)			\
		@$(MKDIR) $(DIR_OBJOUTPUT)
	@if not exist $(DIR_TARGETOUTPUT)		\
		@$(MKDIR) $(DIR_TARGETOUTPUT)
else
	@if	[ ! -e $(DIR_OBJOUTPUT) ]; then 	\
		$(MKDIR) $(DIR_OBJOUTPUT);		\
	fi;
	@if	[ ! -e $(DIR_TARGETOUTPUT) ]; then 	\
		$(MKDIR) $(DIR_TARGETOUTPUT);		\
	fi;
endif

clean:
ifeq ($(OS),Windows_NT)
	@if exist $(DIR_OBJOUTPUT)			\
		@$(RMDIR) $(DIR_OBJOUTPUT)
	@if exist $(DIR_TARGETOUTPUT)			\
		@$(RMDIR) $(DIR_TARGETOUTPUT)
else
	@if	[ -e $(DIR_OBJOUTPUT) ]; then 		\
		$(RMDIR) $(DIR_OBJOUTPUT);		\
	fi;
	@if	[ -e $(DIR_TARGETOUTPUT) ]; then 	\
		$(RMDIR) $(DIR_TARGETOUTPUT);		\
	fi;
endif

-include $(SYS_OBJS_LIST:.o=.d)

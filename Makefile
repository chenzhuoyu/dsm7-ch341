TARGET=ch341.ko

all: $(TARGET)

obj-m := ch341.o

$(TARGET):
	make -C $(KSRC) M=$(PWD) modules

install: $(TARGET)
	mkdir -p $(DESTDIR)/ch341/
	install $< $(DESTDIR)/ch341/

clean:
	rm -rf *.o $(TARGET) *.cmd

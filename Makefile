.PHONY: clean All

All:
	@echo "----------Building project:[ aaa - Debug ]----------"
	@cd "D:\Users\John\Desktop\aaa" && $(MAKE) -f  "aaa.mk"
clean:
	@echo "----------Cleaning project:[ aaa - Debug ]----------"
	@cd "D:\Users\John\Desktop\aaa" && $(MAKE) -f  "aaa.mk" clean

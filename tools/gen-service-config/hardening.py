import copy

class Classifier:
    def __init__(self, service, configs):
        self.service = service
        self.hardenedconfigs = []
        self.configs = configs

    def hardened(self, reconfig = False) -> list[str]:
        if reconfig==False and len(self.hardenedconfigs) > 0:
            return self.hardenedconfigs

        hardenedconfigs = ["[Service]"]
        for conf, possible_values in self.configs.items():
            mutable, config = self.service.mutable(conf)
            if mutable == False:
                #print("\tFound in service config")
                # Initial configs can not be overridden
                hardenedconfigs.append(config)
                print(f"{conf}".ljust(50)+"[✓]")
                continue
            else:
                for val in possible_values:
                    buffer = "\n".join(hardenedconfigs)
                    buffer += f"\n{conf}={val}"
                    print(f"{conf}={val}".ljust(50), end="")

                    if self.service.check_configs(buffer) == True:
                        hardenedconfigs.append(f"{conf}={val}")
                        print("[✓]")
                        break
                    else:
                        print("[✗]")
        self.hardenedconfigs = hardenedconfigs
        return self.hardenedconfigs

class Eliminator:
    def __init__(self, service, baseconfig, config, values):
        self.service = service
        self.baseconf = copy.deepcopy(baseconfig)
        self.capsysconf = []
        self.evalconf = []
        self.config = config
        self.hardenedcaps = False
        for val in values:
            negval = "~" + val
            mutable, _ = service.mutable(negval)
            if mutable == False:
                self.capsysconf.append(f"{config}={negval}")
                continue
            mutable, _ = service.mutable(val)
            if mutable == False:
                self.capsysconf.append(f"{config}={val}")
                self.hardenedcaps = True
                continue
            self.evalconf.append(f"{config}={val}")

    def hardened(self) -> list[str]:
        if self.hardenedcaps == True:
            return self.baseconf + self.capsysconf

        while True:
            testconf = self.evalconf.pop()
            serviceconf = self.baseconf + self.evalconf
            buffer = "\n".join(serviceconf)
            print(f"{testconf}".ljust(50), end="")
            if self.service.check_configs(buffer) == True:
                print("[✓]")
            else:
                self.capsysconf.append(testconf)
                print("[✗]")
            if len(self.evalconf) == 0:
                break

        return self.baseconf + self.capsysconf

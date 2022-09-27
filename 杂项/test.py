import jqdatasdk
jqdatasdk.auth('13558747958', "KanameMadoka9")

# all_index = jqdatasdk.get_all_securities(types="index")
# print(all_index[all_index["name"] == "NDDT"])

NDDT_index = jqdatasdk.get_price("000977.XSHG", start_date="2015-03-10", end_date="2015-03-31", frequency="daily")
print(NDDT_index)
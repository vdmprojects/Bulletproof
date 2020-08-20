import returnABIs from "./returnABIs";

async function buildContracts(_web3) {
  

  const abis = returnABIs();
  

  const STOR_ABI = abis.STOR;
  const NP_ABI = abis.NP;
  const APP_ABI = abis.APP;
  const AC_MGR_ABI = abis.AC_MGR;
  const ECR_ABI = abis.ECR;
  const ECR2_ABI = abis.ECR2;
  const ECR_MGR_ABI = abis.ECR_MGR;
  const ECR_NC_ABI = abis.ECR_NC;
  const A_TKN_ABI = abis.A_TKN;
  const AC_TKN_ABI = abis.AC_TKN;
  const APP_NC_ABI = abis.APP_NC;
  const NP_NC_ABI = abis.NP_NC;
  const NAKED_ABI = abis.NAKED;
  const RCLR_ABI = abis.RCLR;

  const STOR_Address = "0xae0A1529F0FA3Ed53490cE1Dc0E30c5cEa45791d";

  const STOR = new _web3.eth.Contract(STOR_ABI, STOR_Address);

  let APP = null;
  let NP = null;
  let AC_MGR = null;
  let AC_TKN = null;
  let A_TKN = null;
  let ECR_MGR = null;
  let ECR = null;
  let ECR2 = null;
  let ECR_NC = null;
  let APP_NC = null;
  let NP_NC = null;
  let RCLR = null;
  let NAKED = null;

  var _contracts = {
    content: []
  };

  await STOR.methods
    .resolveContractAddress("NP")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        NP = new _web3.eth.Contract(NP_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("NP_NC")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        NP_NC = new _web3.eth.Contract(NP_NC_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("APP")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        APP = new _web3.eth.Contract(APP_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("APP_NC")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        APP_NC = new _web3.eth.Contract(APP_NC_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("AC_MGR")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result)
        AC_MGR = new _web3.eth.Contract(AC_MGR_ABI, _result);
        console.log(AC_MGR)
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("AC_TKN")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        AC_TKN = new _web3.eth.Contract(AC_TKN_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("ECR")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        ECR = new _web3.eth.Contract(ECR_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("ECR2")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        ECR2 = new _web3.eth.Contract(ECR2_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("ECR_NC")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        ECR_NC = new _web3.eth.Contract(ECR_NC_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("ECR_MGR")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        ECR_MGR = new _web3.eth.Contract(ECR_MGR_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("A_TKN")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        A_TKN = new _web3.eth.Contract(A_TKN_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("RCLR")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        RCLR = new _web3.eth.Contract(RCLR_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("NAKED")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        NAKED = new _web3.eth.Contract(NAKED_ABI, _result);
      }
    }
    );

  _contracts.content.push(STOR);     //0
  _contracts.content.push(APP);      //1
  _contracts.content.push(NP);       //2
  _contracts.content.push(AC_MGR);   //3
  _contracts.content.push(AC_TKN);   //4
  _contracts.content.push(A_TKN);    //5
  _contracts.content.push(ECR_MGR);  //6
  _contracts.content.push(ECR);      //7
  _contracts.content.push(ECR2);     //8
  _contracts.content.push(ECR_NC);   //9
  _contracts.content.push(APP_NC);   //10
  _contracts.content.push(NP_NC);    //11
  _contracts.content.push(RCLR);     //12

  console.log(_contracts)
  return _contracts;
  
}

export default buildContracts;

import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

class ModifyRecordStatus extends Component {
  constructor(props){
    super(props);

    this.acctChanger = async () => {
    const ethereum = window.ethereum;
    const self = this;
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function(accounts) {
      _web3.eth.getAccounts().then((e) => self.setState({addr: e[0]}));
    });
    }

    //Component state declaration

    this.state = {
      addr: "",
      error: undefined,
      NRerror: undefined,
      result1: "",
      result2: "",
      AssetClass: "",
      CountDownStart: "",
      ipfs1: "",
      status: "",
      txHash: "",
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      web3: null,
      frontend: "",
      storage: ""
    }

  }

  componentDidMount() {
    //console.log("component mounted")
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({web3: _web3});
    _web3.eth.getAccounts().then((e) => this.setState({addr: e[0]}));
    var addrArray = returnAddresses(); 
    var _frontend_addr = addrArray[1];
    var _storage_addr = addrArray[0];
    const frontEnd_abi = returnFrontEndAbi();
    const storage_abi = returnStorageAbi();

    const _frontend = new _web3.eth.Contract(
    frontEnd_abi,
    _frontend_addr
    );

    const _storage = new _web3.eth.Contract(
    storage_abi, 
    _storage_addr
    );
    this.setState({frontend: _frontend})
    this.setState({storage: _storage})

    document.addEventListener("accountListener", this.acctChanger());

  }

  componentWillUnmount() { 
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger())
}

  render(){
    const self = this;

    async function checkExists(idxHash) { 
      await self.state.storage.methods
        .retrieveRecord(idxHash)
        .call({ from: self.state.addr }, function(_error, _result){
          if(_error){self.setState({error: _error});self.setState({result: 0});alert("WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields.")}
          else{self.setState({result1: _result})}
          console.log("check debug, _result, _error: ", _result, _error)
    });

    }

    async function checkMatch(idxHash, rgtHash) {
      await self.state.storage.methods
        ._verifyRightsHolder(idxHash, rgtHash)
        .call({ from: self.state.addr }, function(_error, _result){
          if(_error){self.setState({error: _error})}
          else if(_result === "0"){;self.setState({result: 0});alert("WARNING: Record DOES NOT MATCH supplied owner info! Reject in metamask and review owner fields.")}
          else{self.setState({result2: _result});}
          console.log("check debug, _result, _error: ", _result, _error)
    });

    }

    const _modifyStatus = () => {
      var idxHash = this.state.web3.utils.soliditySha3(this.state.type, this.state.manufacturer, this.state.model, this.state.serial);
      var rgtRaw = this.state.web3.utils.soliditySha3(this.state.first, this.state.middle, this.state.surname, this.state.id, this.state.secret);
      var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
  
      console.log("idxHash", idxHash);
      console.log("New rgtRaw", rgtRaw);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", this.state.addr);
      
      checkExists(idxHash);
      checkMatch(idxHash, rgtHash);

      this.state.frontend.methods
        ._modStatus(idxHash, rgtHash, this.state.status)
        .send({ from: this.state.addr}).on("error", function(_error){self.setState({error: _error});self.setState({result: _error.transactionHash});})
        .on("receipt", (receipt) => {
          this.setState({txHash: receipt.transactionHash});
          //Stuff to do when tx confirms
        });
    
      console.log(this.state.txHash);
    };

    return (
      <Form className="MRform">
        {this.state.addr === undefined && (
          <div className="errorResults">
            <h2>WARNING!</h2>
            <h3>Injected web3 not connected to form!</h3>
          </div>
        )}
        {this.state.addr > 0 && (
          <Form>
            <h2 className="NRheader">Modify Status</h2>
            <br></br>
            <Form.Row>
              <Form.Group as={Col} controlId="formGridType">
                <Form.Label className="formFont">Type:</Form.Label>
                <Form.Control
                  placeholder="Type"
                  required
                  onChange={(e) => this.setState({ type: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridManufacturer">
                <Form.Label className="formFont">Manufacturer:</Form.Label>
                <Form.Control
                  placeholder="Manufacturer"
                  required
                  onChange={(e) =>
                    this.setState({ manufacturer: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>
            </Form.Row>

            <Form.Row>
              <Form.Group as={Col} controlId="formGridModel">
                <Form.Label className="formFont">Model:</Form.Label>
                <Form.Control
                  placeholder="Model"
                  required
                  onChange={(e) => this.setState({ model: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridSerial">
                <Form.Label className="formFont">Serial:</Form.Label>
                <Form.Control
                  placeholder="Serial"
                  required
                  onChange={(e) => this.setState({ serial: e.target.value })}
                  size="lg"
                />
              </Form.Group>
            </Form.Row>

            <Form.Row>
              <Form.Group as={Col} controlId="formGridFirstName">
                <Form.Label className="formFont">First Name:</Form.Label>
                <Form.Control
                  placeholder="First Name"
                  required
                  onChange={(e) => this.setState({ first: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridMiddleName">
                <Form.Label className="formFont">Middle Name:</Form.Label>
                <Form.Control
                  placeholder="Middle Name"
                  required
                  onChange={(e) =>
                    this.setState({ middle: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridLastName">
                <Form.Label className="formFont">Last Name:</Form.Label>
                <Form.Control
                  placeholder="Last Name"
                  required
                  onChange={(e) => this.setState({ surname: e.target.value })}
                  size="lg"
                />
              </Form.Group>
            </Form.Row>

            <Form.Row>
              <Form.Group as={Col} controlId="formGridIdNumber">
                <Form.Label className="formFont">ID Number:</Form.Label>
                <Form.Control
                  placeholder="ID Number"
                  required
                  onChange={(e) => this.setState({ id: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridPassword">
                <Form.Label className="formFont">Password:</Form.Label>
                <Form.Control
                  placeholder="Password"
                  type="password"
                  required
                  onChange={(e) => this.setState({ secret: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridStatus">
                <Form.Label className="formFont">Status:</Form.Label>
                <Form.Control
                  placeholder="Status"
                  required
                  onChange={(e) => this.setState({ status: e.target.value })}
                  size="lg"
                />
              </Form.Group>
            </Form.Row>
            <Form.Row>
              <Form.Group className="buttonDisplay">
                <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={_modifyStatus}
                >
                  Submit
                </Button>
              </Form.Group>
            </Form.Row>

            {this.state.txHash > 0 && ( //conditional rendering
              <div className="VRresults">
                {this.state.NRerror !== undefined && (
                  <div>
                    ERROR! Please check etherscan
                    <br></br>
                    {this.state.NRerror.message}
                  </div>
                )}
                {this.state.NRerror === undefined && (
                  <div>
                    {" "}
                    No Errors Reported :
                    <a
                      href={
                        "https://kovan.etherscan.io/tx/" + this.state.txHash
                      }
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      KOVAN Etherscan:{this.state.txHash}
                    </a>
                  </div>
                )}
              </div>
            )}
          </Form>
        )}
      </Form>
    );
  }
}

export default ModifyRecordStatus;
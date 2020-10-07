import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import { Home, XSquare, ArrowRightCircle } from "react-feather";

class VerifyLiteMobile extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      error: undefined,
      error1: undefined,
      result: "",
      result1: "",
      assetClass: undefined,
      ipfs1: "",
      txHash: "",
      txStatus: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      isNFA: false,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _accessAsset = async () => {

      if (this.state.manufacturer === ""
        || this.state.type === ""
        || this.state.model === ""
        || this.state.serial === "") {
        return alert("Please fill out all fields before submission")
      }

      let idxHash = window.web3.utils.soliditySha3(
        String(this.state.type),
        String(this.state.manufacturer),
        String(this.state.model),
        String(this.state.serial),
      );

      let doesExist = await window.utils.checkAssetExists(idxHash);

      if (!doesExist) {
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      console.log("idxHash", idxHash);
      // console.log("rgtHash", rgtHash);

      return this.setState({
        idxHash: idxHash,
        // rgtHash: rgtHash,
        accessPermitted: true
      })

    }

    const clearForm = async () => {
      document.getElementById("MainForm").reset();
      this.setState({ result: "" })
    }

    const _verify = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash = this.state.idxHash;

      let rgtRaw = window.web3.utils.soliditySha3(
        String(this.state.first),
        String(this.state.middle),
        String(this.state.surname),
        String(this.state.id),
        String(this.state.secret)
      );

      let rgtHash = window.web3.utils.soliditySha3(String(idxHash), String(rgtRaw));

      console.log("idxHash", idxHash);
      console.log("rgtHash", rgtHash);
      console.log("addr: ", window.addr);

      var doesExist = await window.utils.checkAssetExists(idxHash);
      var infoMatches = await window.utils.checkMatch(idxHash, rgtHash);

      if (!doesExist) {
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      if (!infoMatches) {
        await this.setState({ result: "0" })
      }

      if (infoMatches) { await this.setState({ result: "170" }); }

      return document.getElementById("MainForm").reset();
    };

    return (
      <div>
        <div>
          <div className="mediaLinkAD-home">
            <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
          </div>
          <h2 className="FormHeaderMobile">Verify Lite</h2>
          <div className="mediaLink-clearForm">
            <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { clearForm() }} /></a>
          </div>
        </div>
        <Form className="FormMobile" id='MainForm'>
          <div>
            {!this.state.accessPermitted && (
              <>
                <Form.Row>
                    <Form.Label className="formFont">Type:</Form.Label>
                    <Form.Control
                      placeholder="Type"
                      required
                      onChange={(e) => this.setState({ type: e.target.value })}
                      size="lg"
                    />
                </Form.Row>
                <Form.Row>
                    <Form.Label className="formFont">Manufacturer:</Form.Label>
                    <Form.Control
                      placeholder="Manufacturer"
                      required
                      onChange={(e) => this.setState({ manufacturer: e.target.value })}
                      size="lg"
                    />
                </Form.Row>

                <Form.Row>
                    <Form.Label className="formFont">Model:</Form.Label>
                    <Form.Control
                      placeholder="Model"
                      required
                      onChange={(e) => this.setState({ model: e.target.value })}
                      size="lg"
                    />
                </Form.Row>
                <Form.Row>
                    <Form.Label className="formFont">Serial:</Form.Label>
                    <Form.Control
                      placeholder="Serial"
                      required
                      onChange={(e) => this.setState({ serial: e.target.value })}
                      size="lg"
                    />
                </Form.Row>
                <Form.Row>
                  <div className="submitButtonVRHMobile">
                    <div className="submitButtonVRH-content">
                      <ArrowRightCircle
                        onClick={() => { _accessAsset() }}
                      />
                    </div>
                  </div>
                </Form.Row>
              </>
            )}
            {this.state.accessPermitted && (
              <>
                <Form.Row>
                    <Form.Label className="formFont">First Name:</Form.Label>
                    <Form.Control
                      placeholder="First Name"
                      required
                      onChange={(e) => this.setState({ first: e.target.value })}
                      size="lg"
                    />
                </Form.Row>
                <Form.Row>
                    <Form.Label className="formFont">Middle Name:</Form.Label>
                    <Form.Control
                      placeholder="Middle Name"
                      required
                      onChange={(e) => this.setState({ middle: e.target.value })}
                      size="lg"
                    />
                </Form.Row>
                <Form.Row>
                    <Form.Label className="formFont">Last Name:</Form.Label>
                    <Form.Control
                      placeholder="Last Name"
                      required
                      onChange={(e) => this.setState({ surname: e.target.value })}
                      size="lg"
                    />
                </Form.Row>

                <Form.Row>
                    <Form.Label className="formFont">ID Number:</Form.Label>
                    <Form.Control
                      placeholder="ID Number"
                      required
                      onChange={(e) => this.setState({ id: e.target.value })}
                      size="lg"
                    />
                </Form.Row>
                <Form.Row>
                    <Form.Label className="formFont">Password:</Form.Label>
                    <Form.Control
                      placeholder="Password"
                      type="password"
                      required
                      onChange={(e) => this.setState({ secret: e.target.value })}
                      size="lg"
                    />
                </Form.Row>
                <Form.Row>
                  <div className="submitButtonVRHMobile">
                    <div className="submitButtonVRH-content">
                      <ArrowRightCircle
                        onClick={() => { _verify() }}
                      />
                    </div>
                  </div>
                </Form.Row>
              </>
            )}
          </div>
        </Form>
        <div className="ResultsMobile">

          {this.state.result !== "" && ( //conditional rendering
            <Form.Row>
              {
                this.state.result === "170"
                  ? "Match Confirmed"
                  : "No Match Found"
              }
            </Form.Row>
          )}

        </div>
      </div>
    );
  }
}
export default VerifyLiteMobile;
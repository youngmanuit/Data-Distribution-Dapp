import React from 'react';
import {
    Form,
    InputNumber,
    Modal,
    Button,
    message,
    Tooltip,
    Typography
  } from 'antd';
import 'antd/dist/antd.css';
import {investISO} from '../../api/userAPI'
import {showNotificationTransaction, showNotificationLoading, showNotificationFail} from '../../utils/common'

const { Text } = Typography;
const CollectionCreateForm =
  // eslint-disable-next-line
  class extends React.Component {
      render() {
        const { visible, onCancel, onCreate, form } = this.props;
        const { getFieldDecorator } = form;
        return (
          <Modal
            visible={visible}
            title="Labeling"
            okText="Submit"
            onCancel={onCancel}
            onOk={onCreate}
          >
            <Form layout="horizontal">
              <Form.Item label="labeled File">
                {getFieldDecorator('investAmount', {
                  rules: [{ required: true, message: 'Please input a string!'}],
                  initialValue: 0
                })(
                  <InputNumber
                    min={0}
                    style={{width: 150}}
                    formatter={value => `$ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
                    parser={value => value.replace(/\$\s?|(,*)/g, '')}
                  />
                )}
              </Form.Item>
            </Form>
          </Modal>
        );
      }
    }
    const WrappedLogin = Form.create()(CollectionCreateForm)

export default class InvestISO extends React.Component {
  state = {
    visible: false,
  };

  showModal = () => {
    this.setState({ visible: true });
  };

  handleCancel = () => {
    this.setState({ visible: false });
  };

  handleCreate = () => {
    const { form } = this.formRef.props;
    form.validateFields((err, values) => {
      if(err){
        return message.error('Please fill out all fields');
      }
      this.openUploadNotification(values)
      form.resetFields();
      this.setState({ visible: false });
    });
  };

  openUploadNotification = (values) => {
    showNotificationLoading("Label Loading ...")
    let data = {
      ...values,
      idFile: this.props.idFile
    }
    console.log(data)
    investISO(data)  
    .then((txHash) => {
      showNotificationTransaction(txHash);
    })
    .catch((error) => {
      showNotificationFail(error)
    })  
  }

  saveFormRef = formRef => {
    this.formRef = formRef;
  };
  
  render() {
    return (
      <div>
        <Tooltip title="Label this dataset" placement="leftTop">
          <Button disabled={this.props.disabled} type="primary" ghost icon="bg-colors" onClick={this.showModal}>
            <Text>Label</Text>
          </Button>
        </Tooltip>
        <WrappedLogin
          wrappedComponentRef={this.saveFormRef}
          visible={this.state.visible}
          onCancel={this.handleCancel}
          onCreate={this.handleCreate}
        />
      </div>
    );
  }
}

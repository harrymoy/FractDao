import React from 'react';
import './App.css';
import {BrowserRouter as Router, Route} from "react-router-dom";
import HomePage from './pages/HomePage';
import AppHeader from './components/Header';
import MyAccount from './pages/MyAccount';
import Governance from './pages/Governance';
import Mint from './pages/Mint';

function App() {
  return (
    <>
      <Router>
        <AppHeader/>
        <Route exact path="/" component={HomePage}/>
        <Route exact path="/MyAccount" component={MyAccount}/>
        <Route exact path="/Governance" component={Governance}/>
        <Route exact path="/Mint" component={Mint}/>
      </Router>
    </>
  );
}

export default App;
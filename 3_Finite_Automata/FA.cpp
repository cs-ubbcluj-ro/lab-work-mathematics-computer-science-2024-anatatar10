#include <iostream>
#include <fstream>
#include <set>
#include <map>
#include <vector>
#include <sstream>
using namespace std;

class FiniteAutomaton {
private:
    set<string> states;
    set<char> alphabet;
    map<pair<string, char>, vector<string> > transitions; 
    set<string> finalStates;
    string startState;

public:
    void loadFA(const string &filePath) {
        ifstream file(filePath);
        if (!file) {
            cerr << "Error opening file!" << endl;
            return;
        }

        // Load states
        string line;
        getline(file, line);
        parseStates(line, states);

        // Load alphabet
        getline(file, line);
        parseAlphabet(line, alphabet);

        // Load start state
        getline(file, startState);

        // Load final states
        getline(file, line);
        parseStates(line, finalStates);

        // Load transitions
        while (getline(file, line)) {
            if (!line.empty()) {
                parseTransition(line);
            }
        }

        file.close();
    }

    void displayElements() const {
        cout << "Set of states: ";
        for (set<string>::const_iterator it = states.begin(); it != states.end(); ++it)
            cout << *it << " ";
        cout << endl;

        cout << "Alphabet: ";
        for (set<char>::const_iterator it = alphabet.begin(); it != alphabet.end(); ++it)
            cout << *it << " ";
        cout << endl;

        cout << "Start state: " << startState << endl;

        cout << "Final states: ";
        for (set<string>::const_iterator it = finalStates.begin(); it != finalStates.end(); ++it)
            cout << *it << " ";
        cout << endl;

        cout << "Transitions: " << endl;
        for (map<pair<string, char>, vector<string> >::const_iterator it = transitions.begin(); it != transitions.end(); ++it) {
            cout << "δ(" << it->first.first << ", " << it->first.second << ") -> ";
            for (vector<string>::const_iterator v_it = it->second.begin(); v_it != it->second.end(); ++v_it) {
                cout << *v_it << " ";
            }
            cout << endl;
        }
    }

    bool verifyLexicalToken(const string &inputString) const {
        string currentState = startState;

        for (string::const_iterator it = inputString.begin(); it != inputString.end(); ++it) {
            char symbol = *it;
            pair<string, char> key = make_pair(currentState, symbol);  // Fixed semicolon

            if (transitions.find(key) != transitions.end()) {
                currentState = transitions.at(key)[0]; // Get the next state
            } else {
                return false;  // Invalid transition
            }
        }
        return finalStates.find(currentState) != finalStates.end();
    }

private:
    void parseStates(const string &line, set<string> &stateSet) {
        stringstream ss(line);
        string state;
        while (ss >> state) {
            stateSet.insert(state);
        }
    }

    void parseAlphabet(const string &line, set<char> &alphabetSet) {
        stringstream ss(line);
        char symbol;
        while (ss >> symbol) {
            alphabetSet.insert(symbol);
        }
    }

    void parseTransition(const string &line) {
        stringstream ss(line);
        string fromState, toState;
        char symbol;
        ss >> fromState >> symbol >> toState;

        pair<string, char> key = make_pair(fromState, symbol);
        transitions[key].push_back(toState);
    }
};

int main() {
    FiniteAutomaton fa;
    fa.loadFA("FA.in");

    fa.displayElements();

    // BONUS: Verify if a given string is a valid lexical token
    string inputString;
    cout << "Enter a string to verify if it's a valid lexical token: ";
    cin >> inputString;

    if (fa.verifyLexicalToken(inputString)) {
        cout << "'" << inputString << "' is a valid lexical token." << endl;
    } else {
        cout << "'" << inputString << "' is NOT a valid lexical token." << endl;
    }

    return 0;
}

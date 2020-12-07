import scipy.io
import pylab
import numpy as np
from random import randint
from random import random
from keras.layers import Dense
from keras.models import Sequential
from keras.optimizers import Adam
from keras import backend as K


# Load input data
DATA = scipy.io.loadmat('./test.mat')       # MATLAB data
INPUT = DATA['input']                       # [x,y,q,r]
OUTPUT = DATA['output']                     # [L or G]
TRIALS = len(DATA) - 1                      # Number of trials -1 cause it starts from 0
EPISODES = 500                              # Number of training episodes


#Normalize input
x_max = np.max(INPUT[:,0]);
x_min = np.min(INPUT[:,0]);
y_max = np.max(INPUT[:,1]);
y_min = np.min(INPUT[:,1]);
q_max = np.max(INPUT[:,2]);
q_min = np.min(INPUT[:,2]);
r_max = np.max(INPUT[:,3]);
r_min = np.min(INPUT[:,3]);

for i in range(INPUT.shape[0]) :
    INPUT[i][0] = (INPUT[i][0] - x_min)/(x_max-x_min + 0.0001);
    INPUT[i][1] = (INPUT[i][1] - y_min)/(y_max-y_min + 0.0001);
    INPUT[i][2] = (INPUT[i][2] - q_min)/(q_max-q_min + 0.0001);
    INPUT[i][3] = (INPUT[i][3] - r_min)/(r_max-r_min + 0.0001);

replay_buffer = list();

# Uncertainty-Value Model (Proposed Model)
class UVModel:
    def __init__(self, state_size, action_size):
        self.load_model = False             # Load saved model

        # Initialize the state size & action size
        self.state_size = state_size
        self.action_size = action_size
        self.value_size = 1

        # Hyperparameter setting
        self.discount_factor = 1
        self.actor_lr = 0.001
        self.critic_lr = 0.001

        # Build Actor & Critic
        self.actor = self.build_actor()
        self.critic = self.build_critic()
        self.actor_updater = self.actor_optimizer()
        self.critic_updater = self.critic_optimizer()

        # Load saved model for test
        if self.load_model:
            self.actor.load_weights("./Uncertainty_Value_model_Actor.h5")
            self.critic.load_weights("./Uncertainty_Value_model_Critic.h5")

    # actor: computes the probability of actions (softmax)
    def build_actor(self):
        actor = Sequential()
        actor.add(Dense(24, input_dim=self.state_size, activation='relu',
                        kernel_initializer='he_uniform'))
        actor.add(Dense(self.action_size, activation='softmax',
                        kernel_initializer='he_uniform'))
        actor.summary()
        return actor

    # critic: computes the value of actions
    def build_critic(self):
        critic = Sequential()
        critic.add(Dense(24, input_dim=self.state_size, activation='relu',
                         kernel_initializer='he_uniform'))
        critic.add(Dense(self.value_size, activation='linear',
                         kernel_initializer='he_uniform'))
        critic.summary()
        return critic

    # Choose action
    def get_action(self, state, eps):
        policy = self.actor.predict(state, batch_size=1).flatten()

        # random choice with epsilon degree;

        if random() < eps :
            return np.random.choice(self.action_size, 1, p= [0.5, 0.5])[0];
        else :
            return np.random.choice(self.action_size, 1, p=policy)[0]


    # Updates policy
    def actor_optimizer(self):
        action = K.placeholder(shape=[None, self.action_size])
        advantage = K.placeholder(shape=[None, ])

        action_prob = K.sum(action * self.actor.output, axis=1)
        cross_entropy = K.log(action_prob) * advantage
        loss = -K.sum(cross_entropy)

        optimizer = Adam(lr=self.actor_lr)
        updates = optimizer.get_updates(self.actor.trainable_weights, [], loss)
        train = K.function([self.actor.input, action, advantage], [],
                           updates=updates)

        return train

    # Updates value
    def critic_optimizer(self):
        target = K.placeholder(shape=[None, ])


        loss = K.mean(K.square(target - self.critic.output))

        optimizer = Adam(lr=self.critic_lr)
        updates = optimizer.get_updates(self.critic.trainable_weights, [], loss)
        train = K.function([self.critic.input, target], [], updates=updates)

        return train

    # Update Actor & Critic at every time step
    def train_model(self, state, action, reward, next_state, done):

        value = self.critic.predict(state)
        next_value = self.critic.predict(next_state)
        # print("value:", value, " next_vale", next_value)

        act = np.zeros([action.shape[0], self.action_size])
        advan_list = list();
        target_list= list();
        for ii in range(action.shape[0]) :
            act[ii][int(action[ii])] = 1;

            # Update using Bellman equation
            if done[ii]:
                advantage = reward[ii] - value[ii]
                target = [reward[ii]]
            else:
                advantage = (reward[ii] + self.discount_factor * next_value[ii]) - value[ii]
                target = reward[ii] + self.discount_factor * next_value[ii]
            advan_list.append(advantage);
            target_list.append(target);

                # print("advantage:", advantage, " target:", target)

        self.actor_updater([state, act, np.squeeze(np.stack(advan_list))])

        self.critic_updater([state, np.squeeze(np.stack(target_list))])

def sample_from_replay(size, batch_size=10)  :

    sampled_idx = np.zeros(shape=(batch_size,), dtype=int);
    for i in range(batch_size) :
        sampled_idx[i] = randint(0,size-1);
    return sampled_idx;

if __name__ == "__main__":
    state_size = 4                          # state = [x,y,q,r]
    action_size = 2                         # action = [G or L]
    epsilon_start_value = 0.99;


    # Build Actor-Critic agent
    agent = UVModel(state_size, action_size)

    # Initialize scores and trials
    scores, trials = [], []

    count = 0                               # number for plotting
    epsilon = epsilon_start_value;
    #  Training
    for e in range(EPISODES):
        print("=====================  Episode: ", e, " ===========================")
        done = False
        score = 0

        for t in range(TRIALS):

            state = INPUT[t]
            state = np.reshape(state, [1, state_size])
            epsilon = epsilon*0.99; ########################################################################################
            action = agent.get_action(state, epsilon)

            next_state = INPUT[t + 1]
            next_state = np.reshape(next_state, [1, state_size])

            answer = OUTPUT[t+1]
            if answer == action:
                reward = 1
            else:
                reward = -1
                next_state = [0.0, 0.0, 0.0, 0.0]; ######################################################################
                done = True;


            #done = False

            if len(replay_buffer) < 50 :   ######################################################################
                replay_buffer.append([state, action, reward, next_state, done])
            else :
                replay_buffer.pop(0);
                replay_buffer.append([state, action, reward, next_state, done])


            idx = sample_from_replay(len(replay_buffer), batch_size = 2);                           ######################################################################
            # randomly shuffle replay buffer
            replay_state = np.zeros(shape=(idx.shape[0], state.shape[1]));
            replay_action = np.zeros(shape=(idx.shape[0], ));
            replay_reward = np.zeros(shape=(idx.shape[0], ));
            replay_next_state = np.zeros(shape=(idx.shape[0], state.shape[1]));
            replay_done = np.zeros(shape=(idx.shape[0], ));

            for dat_idx in range(idx.shape[0]) :
                replay_state[dat_idx] = replay_buffer[idx[dat_idx]][0];
                replay_action[dat_idx] = replay_buffer[idx[dat_idx]][1];
                replay_reward[dat_idx] = replay_buffer[idx[dat_idx]][2];
                replay_next_state[dat_idx] = replay_buffer[idx[dat_idx]][3];
                replay_done[dat_idx] = replay_buffer[idx[dat_idx]][4];

            agent.train_model(replay_state, replay_action, replay_reward , replay_next_state, replay_done);

            score = reward
            state = next_state

            # Print results
            scores.append(score)
            trials.append(count)
            count += 1
            print("trial:", count, "  score:", score, " action prediction:", action, " output:", answer)
            if done == True :
                break;

        # agent.actor.save_weights("./Uncertainty_Value_model_Actor.h5")
        # agent.critic.save_weights("./Uncertainty_Value_model_Critic.h5")
        # sys.exit()

    pylab.plot(trials, scores, 'b')
    pylab.savefig("./Uncertainty_Value_Model.png")

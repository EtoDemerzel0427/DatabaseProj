import pandas as pd
import numpy as np

def check_cell(df):
    """
    :param df: dataframe,
    :return: a new dataframe, with all invalid items filtered
    """
    df_new = df.copy()

    for index, row in df.iterrows():
        if not (not pd.isnull(row['SECTOR_ID']) and
                not pd.isnull(row['SECTOR_NAME']) and
                not pd.isnull(row['ENODEBID']) and
                not pd.isnull(row['ENODEB_NAME']) and
                not pd.isnull(row['EARFCN']) and
                row['EARFCN'] in [37900, 38098, 38400, 38950, 39148] and
                row['PCI'] >= 0 and row['PCI'] <= 503 and
                row['PCI'] == 3 * row['SSS'] + row['PSS'] and
                row['PSS'] >= 0 and row['PSS'] <= 3 and
                row['SSS'] >= 0 and row['SSS'] <= 167 and
                row['VENDOR'] in ['华为', '中兴', '诺西', '爱立信', '贝尔', '大唐'] and
                not pd.isnull(row['LONGITUDE']) and
                not pd.isnull(row['LATITUDE']) and
                row['STYLE'] in ['宏站', '室内', '室外'] and
                not pd.isnull(row['AZIMUTH']) and
                not pd.isnull(row['TOTLETILT']) and
                row['TOTLETILT'] == row['ELECTTILT'] + row['MECHTILT']):
            df_new = df_new.drop([index])

    return df_new


def check_prb(df):
    new_name = ['startTime', 'turnround', 'neName', 'cell', 'cellName', 'PRB0', 'PRB1', 'PRB2', 'PRB3', 'PRB4', 'PRB5',
                'PRB6', 'PRB7', 'PRB8', 'PRB9', 'PRB10', 'PRB11', 'PRB12', 'PRB13', 'PRB14', 'PRB15', 'PRB16', 'PRB17',
                'PRB18', 'PRB19', 'PRB20', 'PRB21', 'PRB22', 'PRB23', 'PRB24', 'PRB25', 'PRB26', 'PRB27', 'PRB28',
                'PRB29', 'PRB30', 'PRB31', 'PRB32', 'PRB33', 'PRB34', 'PRB35', 'PRB36', 'PRB37', 'PRB38', 'PRB39',
                'PRB40', 'PRB41', 'PRB42', 'PRB43', 'PRB44', 'PRB45', 'PRB46', 'PRB47', 'PRB48', 'PRB49', 'PRB50',
                'PRB51', 'PRB52', 'PRB53', 'PRB54', 'PRB55', 'PRB56', 'PRB57', 'PRB58', 'PRB59', 'PRB60', 'PRB61',
                'PRB62', 'PRB63', 'PRB64', 'PRB65', 'PRB66', 'PRB67', 'PRB68', 'PRB69', 'PRB70', 'PRB71', 'PRB72',
                'PRB73', 'PRB74', 'PRB75', 'PRB76', 'PRB77', 'PRB78', 'PRB79', 'PRB80', 'PRB81', 'PRB82', 'PRB83',
                'PRB84', 'PRB85', 'PRB86', 'PRB87', 'PRB88', 'PRB89', 'PRB90', 'PRB91', 'PRB92', 'PRB93', 'PRB94',
                'PRB95', 'PRB96', 'PRB97', 'PRB98', 'PRB99']
    mapping = dict(zip(list(df.columns), new_name))
    df.rename(columns=mapping, inplace=True)
    # df = df.replace('NIL', np.NaN)
    # df_new = df.copy()
    df_new = df.drop(df[df['startTime'].isnull().values].index)
    df_new = df_new.drop(df[df['cell'].isnull().values].index)

    return df_new


def check_kpi(df):
    new_name = ['startTime', 'turnround', 'neName', 'cell', 'cellName', 'rrcSucTime', 'rrcReqTime', 'rrcSucRate',
                'erabSucTime', 'erabReqTime', 'erabSucRate', 'enodebException', 'cellException', 'erabOfflineRate',
                '_O', '_P', '_Q', '_R', '_S', '_T', '_U', '_V', '_W', '_X', '_Y', '_Z', '_AA', '_AB', '_AC', '_AD',
                '_AE', '_AF', '_AG', '_AH', '_AI', '_AJ', '_AK', '_AL', '_AM', '_AN', '_AO', '_AP']
    mapping = dict(zip(list(df.columns), new_name))
    df.rename(columns=mapping, inplace=True)
    # df = df.replace('NIL', np.NaN)

    df_new = df.drop(df[df['startTime'].isnull().values].index)
    df_new = df_new.drop(df[df['cell'].isnull().values].index)

    return df_new




def check_mro(df):
    df_new = df.copy()
    df_new = df_new.drop(df[df['TimeStamp'].isnull().values].index)
    df_new = df_new.drop(df[df['ServingSector'].isnull().values].index)
    df_new = df_new.drop(df[df['InterferingSector'].isnull().values].index)

    return df_new

if __name__ == '__main__':
    path = r'C:\Users\huang\Desktop\2019数据库课程设计\三门峡地区TD-LTE网络数据-2017-03\12.tbKPI.xlsx'
    df = pd.read_excel(path)
    df = check_kpi(df)
    sub = df.iloc[0:1]
    print(sub.to_dict('records'))
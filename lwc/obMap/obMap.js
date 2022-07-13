import { LightningElement } from 'lwc';

export default class ObMap extends LightningElement {
    mapMarkers = [
        {
            location: {
                Country: 'Portugal',
                Street: '6P44+95 Selores',
            },
            icon: 'standard:account',
        },
    ];
}